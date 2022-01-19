from playwright.sync_api import sync_playwright
from tqdm import tqdm
import re,time
from datetime import datetime
import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import random 

#conn=create_engine('sqlite:///area.sqlite3')
conn = create_engine('postgresql+psycopg2://qllwx:qllwx@100.88.6.173:5432/csh_development')
base_url='http://www.csh.moe.edu.cn/MOETC/login/loginAction!getAllSchool.action'
host='http://www.csh.moe.edu.cn/MOETC/'

def get_provinces():
    df=pd.read_sql_table('provinces',conn)
    return df
def get_cities():
    df=pd.read_sql_table('cities',conn)
    return df
def get_county(filter='All'):
    df=pd.read_sql_table('counties',conn)
   
    return df
def get_schools(filter='All'):
    df=pd.read_sql_table('schools',conn)   
    return df
def get_areas(filter='All'):
    if filter=='All':
        df=pd.read_sql_table('areas',conn)   
    else:
        df=pd.read_sql("select * from areas where %s"%filter,conn)
    return df

def get_school_count(page):
    totalPages=page.text_content('span.totalPages')
    res= re.findall('\d+',totalPages)
    total={'pages':res[0],'schools':res[1]}
    return total
def savetotalschools(total,code):    
    conn.execute("update areas set total_schools=%s where code like '%s'"%(total,code))

def checkschooldownloaded(areaId,total):
    res=conn.execute('select count(*) from schools where area_id =%s'%areaId).fetchone()
    if (res  == None):
        return False
    elif int(res[0]) == int(total):
        return True
    else:
        return False
    
    
def getProvinceSchools(provinceIds=None):
    if  provinceIds is None:
        df=get_provinces()
       
        ids=list(df.code)
        provinceIds=list(map(lambda x: int(x[0:2]),ids))
        
    for provId in tqdm(provinceIds):
        getAllSchools(provId)

def getCitySchools(provinceIds=None):
    if  provinceIds is None:
        provinces_list=get_provinces()
        df=pd.DataFrame.from_records(provinces_list)
        ids=list(df.code)
        provinceIds=list(map(lambda x: int(x[0:2]),ids))
        
    for provId in tqdm(provinceIds):
        city_list=get_cities(str(provId)[0:2]+'0'*10)
        df=pd.DataFrame.from_records(city_list)
        ids=list(df.code)
        cityIds=list(map(lambda x: int(x[0:4]),ids))
        for cityId in tqdm(cityIds):
            getAllSchools(cityId)

def getCountySchools(provinceIds=None):
    if  provinceIds is None:
        provinces_list=get_provinces()
        df=pd.DataFrame.from_records(provinces_list)
        ids=list(df.code)
        provinceIds=list(map(lambda x: int(x[0:2]),ids))
        
    for provId in tqdm(provinceIds):
        city_list=get_cities(str(provId)[0:2]+'0'*10)
        df=pd.DataFrame.from_records(city_list)
        ids=list(df.code)
        cityIds=list(map(lambda x: int(x[0:4]),ids))
        for cityId in tqdm(cityIds):
            county_list=get_county(str(cityId)[0:4]+'0'*8)
            df=pd.DataFrame.from_records(county_list)
            ids=list(df.code)
            counIds=list(map(lambda x: int(x[0:6]),ids))
            for counId in tqdm(counIds):
                getAllSchools(counId)

        

#with playwright  open county schools list the get and save to database.
def getAllSchools(df_row):
    School_all=[]
    Total=0
   
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        url=df_row.href_query
        page.goto(host+url)
       
        Total=get_school_count(page)
        totalPages=int(Total['pages'])
        print(df_row,totalPages,Total['schools'])
        if checkschooldownloaded(areaId=df_row.id,total=Total['schools']):
            browser.close()
            return
        
        savetotalschools(total=Total['schools'],code=df_row.code)       
        areaId=df_row.code
        
       
        for i in tqdm(range(totalPages)):
            schools=pageGetSchools(page,areaId=areaId)
            #saveSchools(schools)
            School_all.append(schools)
            #print(len(School_all))
            page.click('text=下一页')
            saveSchools(schools)

        browser.close()

    


def pageGetSchools(page,areaId):

    table=page.text_content('table.h_list-table').replace(' ','').split()
    if len(table)<22:
        time.sleep(0.1)
        table=page.text_content('table.h_list-table').replace(' ','').split()
    table=table2schools(table,areaId=areaId)
    return table

def table2schools(table,areaId):
    a=str(areaId)
    city_id,county_id=a[0:4],a[0:6]
    schools=[]
    for i in range(2,len(table),2):
        try:
            school_dict={'name':table[i],
                        'code':table[i+1],
                        'area_id':areaId,
                        'city_id':city_id,
                        'county_id':county_id
                        }
        except Exception as e:
            print(e.args)
        else:
            schools.append(school_dict)
    return schools 

def saveSchools(schools):
    for school in schools:
        #print(school)
        sql="select id from areas where code like '%s'"%(school['area_id'])
        areaId=conn.execute(sql).fetchone()[0]
        res=conn.execute("select * from schools where code like '%s'"%school['code']).fetchone()
        
        if not (res  == None):
            sql="update schools set county_code='%s' where code like '%s'"%(school['county_id'],school['code'])
        else:
          sql="insert into schools (code ,name,area_id,county_code,created_at,updated_at) values('%s','%s',%s,'%s','%s','%s')"% \
                        (school['code'],school['name'],areaId,school['county_id'],datetime.now(),datetime.now())

        try:
            conn.execute(sql)

        except Exception as e:
            print("%s Error:%s"%(school['name'],e.args))
        else:
            print(school['name'],"saved OK!")




def getareaSchools():
    df=get_areas(filter="total_schools is Null")
    l=len(df) 
    if l >50:
        k=int(l/15)
    else:
        k=l

    for row in tqdm(random.choices(range(l),k=k)):
        getAllSchools(df.iloc[row,:])

if __name__== '__main__':
    getareaSchools()

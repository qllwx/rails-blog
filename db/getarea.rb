require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'active_record'
require 'fileutils'
filename='area.sqlite3'
destfile=Date.today.year.to_s+'_'+filename
if File.file?('area.sqlite3')
    FileUtils.cp(filename,destfile)
    return
end

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'area.sqlite3'

) 
class CreateProvinces < ActiveRecord::Migration[7.0]
    def change
      create_table :provinces do |t|
        t.string :code
        t.string :name
        t.integer :total_schools
        t.string :href_query
        t.string :category
        t.timestamps
      end
    end
end
CreateProvinces.migrate(:up)
class Province < ActiveRecord::Base
    has_many :cities
end
# Print information about the database table
#Province.columns.each {|row| puts row.name,row.type}
# Drop the table
#CreateProvinces.migrate(:down)
class CreateCities < ActiveRecord::Migration[7.0]
    def change
      create_table :cities do |t|
        t.string :code
        t.string :name
        t.integer :total_schools
        t.string :href_query
        t.string :category
        t.references :provinces, null: false, foreign_key: true
        t.timestamps
      end
    end
end
CreateCities.migrate(:up)
class City <ActiveRecord::Base
    belongs_to :provinces
    has_many :counties
end
class CreateCounties < ActiveRecord::Migration[7.0]
    def change
      create_table :counties do |t|
        t.string :code
        t.string :name
        t.integer :total_schools
        t.string :href_query
        t.string :category
        t.references :cities , null: false, foreign_key: true
        t.timestamps
      end
    end
end
CreateCounties.migrate(:up)
class County <ActiveRecord::Base
    belongs_to :cities
end



class CreateAreas < ActiveRecord::Migration[7.0]
    def change
      create_table :areas do |t|
        t.string :code
        t.string :name
        t.string :provinceName 
        t.string :cityName
        t.string :countyName
        t.integer :total_schools
        t.string :href_query
        t.string :category
        t.timestamps
      end
    end
  end
CreateAreas.migrate(:up)
class Area < ActiveRecord::Base
    has_many :schools
end
# Print information about the database table

# Drop the table
#CreateAreas.migrate(:down)
class CreateSchools < ActiveRecord::Migration[7.0]
    def change
      create_table :schools do |t|
        t.string :code,unique: true
        t.string :name       
        t.string :countyCode
        t.integer :studentTotal
        t.integer :excellentTotal
        t.integer :goodTotal
        t.integer :passTotal
        t.integer :failTotal
        t.integer :missExamTotal
        t.string :category
        t.references :area, null: false, foreign_key: true
  
        t.timestamps
      end
    end
end
CreateSchools.migrate(:up)
class School < ActiveRecord::Base
    belongs_to :areas
end
# Drop the table
#CreateSchools.migrate(:down)

def query_parser(query)
    res={}
    list=query.split('&')
    list.each do |l|
        res[l.split('=')[0]]=l.split('=')[1]
    end
    res.to_a
end

class Myarea 
    def initialize url
       @doc =Nokogiri::HTML5(URI.open(url))
    end
    def getarea area
        @@area_dict={"province"=>0,"city"=>1,"county"=>2 }
        css="div.h_select_line_right"
        name=@doc.search(css)[@@area_dict[area]].text.split
        href=@doc.search(css)[@@area_dict[area]].search('a').map {|link| link['href'] }
        res=[]
        (0...name.count).each do |i|
            res.append [@@area_dict[area],name[i],href[i]]
        end
        res
    end
    def province
        self.getarea('province')
    end
    def city
        self.getarea('city')
    end
    def county
        self.getarea("county")
    end
end

City.columns.each { |column|
  puts column.name
  puts column.type
}

base_url='http://www.csh.moe.edu.cn/MOETC/login/loginAction!getAllSchool.action'
host='http://www.csh.moe.edu.cn/MOETC/'

a=Myarea.new base_url
geturl=a.province
geturl.each {|row|
    Province.new(name: row[1],href_query: row[2],category: row[0]).save
    Area.new(name: row[1],
        href_query:row[2],
        category:  row[0],
        provinceName: row[1],
        cityName:  row[1],
        countyName: row[1]

    ).save
}
puts Province.count,Area.count


Province.all().each do |p_row|
    #host='http://www.csh.moe.edu.cn/MOETC/'
    c= Myarea.new host+p_row.href_query
    geturl=c.city
    geturl.each  do |row|
            City.new(provinces_id:p_row.id,
                     name: row[1],href_query: row[2],category: row[0]).save
            Area.new(name: row[1],
                    href_query:row[2],
                    category:  row[0],
                    provinceName: row[1],
                    cityName:  row[1],
                    countyName: p_row.name

                ).save
            puts p_row.name+'-'+row[1],City.count
    end    
end
puts Area.count,Province.count,City.count,County.count

City.all().each do |c_row|
    #host='http://www.csh.moe.edu.cn/MOETC/' 
    p_row=Province.find(c_row.provinces_id)
    c= Myarea.new host+c_row.href_query
    geturl=c.county
    geturl.each {|row|
                County.new(cities_id:c_row.id,
                    name: row[1],href_query: row[2],category: row[0]).save
                Area.new(name: row[1],
                    href_query:row[2],
                    category:  row[0],
                    provinceName: row[1],
                    cityName:  c_row.name,
                    countyName: p_row.name

                ).save
            puts p_row.name+'-'+c_row.name+'-'+row[1],County.count
        }    
end
puts Area.count,Province.count,City.count,County.count
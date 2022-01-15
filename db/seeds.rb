# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

mysiteConnect=PG::Connection.new(:host=> '4.qllwx.cn',
                                  :user=>'qllwx',
                                  :password=>'tun132',
                                  :dbname=>'mysite',
                                  :port=>'5432' 
)

areaSet=mysiteConnect.exec('select id,code,name,total_web_schools from csh_area')
if areaSet.count > Area.count
    areaSet.each do |row|
        Area.create(id: row['id'],
                code: row['code'],
                name: row['name'],
                total_schools: row['total_web_schools'])
        puts row['name']
    end
end


schoolSet=mysiteConnect.exec('select id,code,name,total_students area_id,city_id,county_id,yx,lh,jg,bjg,qk,category from csh_school')
if schoolSet.count > School.count
    schoolSet.each do |row|
        School.create(id: row['id'],
                code: row['code'],
                name: row['name'],
                total_students: row['total_students'],
                yx:row['yx'],lh:row['lh'],jg:row['jg'],bjg:row['bjg'],qk:row['qk'],
                category: row['category']
                )
        puts row['name']
    end
end

mysiteConnect.close
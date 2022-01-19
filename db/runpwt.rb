require 'playwright'

base_url='http://www.csh.moe.edu.cn/MOETC/login/loginAction!getAllSchool.action'
host='http://www.csh.moe.edu.cn/MOETC/'

Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page
    page.goto(base_url)
    total = page.query_selector("span.totalPages")
    puts total
  end
end
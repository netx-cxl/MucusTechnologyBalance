
if ENV["OCRA_EXECUTABLE"]
  Dir.chdir(File.dirname(ENV["OCRA_EXECUTABLE"]))
end

require_relative 'recipes001'
require_relative 'balance002'
require 'json'
require 'fileutils'

FileUtils.mkdir_p("result")

plans = {}
Dir.glob("plan/*.json").each do |path|
  data = JSON.parse(File.read(path, encoding: "UTF-8"))
  plans[data["name"]] = data

  errors = []
  levels = {}

  if data["pattern"] == "make"
    Balance.run(data["name"], data["make_number"], 0, levels, errors)
  end

  base = File.basename(path, ".json")          
  out  = "result/#{base}_result.txt"

  File.open(out, "w", encoding: "UTF-8") do |f|
    f.puts "===== 配平结果 ====="
    levels.each do |lv, items|
      f.puts "#{lv}级:"
      items.each { |n, c| f.puts "  #{n} x #{c}" }
      f.puts
    end

    f.puts "===== 基础材料总计 ====="
    totals = {}
    levels.each do |_lv, items|
      items.each do |n, c|
        item = Recipes.recipes_find(n)
        if item.nil? || item["kind"] == "raw_material"
          totals[n] = totals.fetch(n, 0) + c
        end
      end
    end

    if totals.empty?
      f.puts "（无）"
    else
      totals.each { |n, c| f.puts "#{n} x #{c}" }
    end

    f.puts "===== 警告 / 错误 ====="
    f.puts(errors.empty? ? "（无）" : errors.join("\n"))
  end

  puts "已输出: #{out}"
end
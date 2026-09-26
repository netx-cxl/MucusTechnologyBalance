require_relative 'recipes001'

#level0 = 产物的合成材料*数量
#跑一次是单次查询
#判断材料配方有就判断是否可合成，同级有相同就累加

module Balance

  def self.run(name,amount,level = 0,levels = {},errors = [])

    item = Recipes.recipes_find(name)
    

    levels[level] ||= {}
    levels[level][name] = levels[level].fetch(name, 0) + amount

    if item.nil?
      errors << "第 #{level} 级找不到配方: #{name}（需要 #{amount} 个）"
      return levels
    end

    return levels if item["kind"] == "raw_material"

    out_count = item["out_result"][name]
    if out_count.nil? || out_count == 0
      errors << "#{name} 的 out_result 里没有自己的数量，无法计算"
      return levels
    end

    make_count = (amount.to_f/item["out_result"][name]).ceil

    item["put_materials"].each do |mat_name,mat_value|
      
      Balance.run(mat_name,mat_value*make_count,level+1,levels,errors)

    end

    levels
  end

end
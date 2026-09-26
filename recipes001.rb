require 'json';

module Recipes

    def self.load_recipes
      items = {}
      Dir.glob("composition/*.json").each do |path|
        data = JSON.parse(File.read(path, encoding: "UTF-8"))
        next if data["pattern"] == "make"
        items[data["name"]] = data
      end
      items
    end

    RECIPES = load_recipes   # 全局只加载一次

    def self.recipes_search(name)

      item = RECIPES[name]
      return nil if item.nil?
      item["out_result"] 

    end

    def self.recipes_find(name)
      RECIPES[name]
    end
end


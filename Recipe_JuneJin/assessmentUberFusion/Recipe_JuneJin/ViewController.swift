//
//  ViewController.swift
//  Recipe_JuneJin
//
//  Created by Nicholas Ngoh on 23/04/2022.
//

import UIKit

struct Recipe : Codable {
    var recipeId = String()
    var image_url = String()
    var title = String()
    var method: [String] = []
    var ingredient: [Ingredient] = []
    var time: Time = Time()
}

struct Ingredient: Codable {
    var name = String()
    var quantity = String()
    var unit = String()
}

struct Time: Codable {
    var quantity = String()
    var unit = String()
}

class ViewController: UITableViewController, XMLParserDelegate {
    var currentElement = String()
    var recipeId = String()
    var recipes: [Recipe] = []
    var recipe = String()
    var titleString = String()
    var image_url = String()
    var method: [String] = []
    var ingredient: [Ingredient] = []
    var time: Time = Time()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parseSuccess = parseRecipeList()
        
        if !parseSuccess {
            
        }
    }
    
    func parseRecipeList() -> Bool {
        if let path = Bundle.main.path(forResource: "recipetypes", ofType: "xml") {
            if let parser = XMLParser(contentsOf: URL(fileURLWithPath: path)) {
                parser.delegate = self
                
                if parser.parse() {
                    return true
                } else {
                    print("Unable to parse")
                    return false
                }
            }
        }

        print("Unable to find the XML file")
        return false
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "recipe":
            if let id = attributeDict["id"] {
                recipeId = id
            }
            titleString = String()
            method = []
            ingredient = []
            time = Time()
        case "ingredient":
            var temp = Ingredient()
            
            if let name = attributeDict["name"] {
                temp.name = name
            }
            if let quantity = attributeDict["quantity"] {
                temp.quantity = quantity
            }
            if let unit = attributeDict["unit"] {
                temp.unit = unit
            }
            
            ingredient.append(temp)
        case "time":
            if let quantity = attributeDict["quantity"] {
                time.quantity = quantity
            }
            if let unit = attributeDict["unit"] {
                time.unit = unit
            }
        default: break
        }
        self.currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "recipe" {
            let recipe = Recipe(recipeId: recipeId, image_url: image_url, title: titleString, method: method, ingredient: ingredient, time: time)
            recipes.append(recipe)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if (!data.isEmpty) {
            if self.currentElement == "title" {
                titleString += data
            } else if self.currentElement == "step" {
                method.append(data)
            } else if self.currentElement == "image_url" {
                image_url = data
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let recipe = recipes[indexPath.row]

        cell.textLabel?.text = recipe.title

        return cell
    }
}

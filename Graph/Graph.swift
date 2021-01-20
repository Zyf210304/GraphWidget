//
//  Graph.swift
//  Graph
//
//  Created by 亚飞 on 2021/1/20.
//

import WidgetKit
import SwiftUI
import Intents


struct Model : TimelineEntry {
    
    var date : Date
    var widgetDate: [JSONModel]
    
    
}


struct JSONModel : Decodable, Hashable{
    
    var date : CGFloat
    var units : CGFloat
    
}


struct Provider : TimelineProvider {
    
    func placeholder(in context: Context) -> Model {
        Model(date: Date(), widgetDate: Array(repeating: JSONModel(date: 0, units: 0), count: 6))
    }
    
    
    typealias Entry = Model
    
    
    func getSnapshot(in context: Context, completion: @escaping (Model) -> Void) {
        
        let loadingData = Model(date: Date(), widgetDate: Array(repeating: JSONModel(date: 0, units: 0), count: 6))
        
        completion(loadingData)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
        
        getData { (modelData) in
            
            let date = Date()
            
            let data = Model(date: date, widgetDate: modelData)
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: date)
            
            let timeline = Timeline(entries: [data], policy: .after(nextUpdate!))
            
            completion(timeline)
        }
        
    }
}


struct WidgetView : View {
    
    var data : Model
    
    var colors = [Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), Color(#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)), Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)),Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)), Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)), Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))]
    
    var body: some View {
        

            
            VStack(alignment: .leading, spacing: 15) {
                
                Text("Units Sold")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                HStack(spacing:15) {
                    
                    ForEach(data.widgetDate, id:\.self) { value in
                        
                        if value.units == 0 && value.date == 0 {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray)
                        }
                        else {
                            
                            VStack(spacing: 15) {
                                
                                Text("\(Int(value.units))")
                                    .fontWeight(.bold)
                                
                                GeometryReader { g in

                                    VStack {

                                        Spacer(minLength: 0)
                                        
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(colors.randomElement()!)
                                            .frame(height:getHeight(value: CGFloat(value.units), height: g.frame(in: .global).height))

                                    }
                                    
                                }
                                
                                Text(getData(value: value.date))
                                    .font(.caption2)
                               
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
                
            }
            .padding()
        
        
    }
    
    func  getHeight(value: CGFloat, height: CGFloat) -> CGFloat  {
        
        let max = data.widgetDate.max { (first, second) -> Bool in
            
            if first.units > second.units {return false}
            else {return true}
            
        }
        
        let percent = value / CGFloat(max!.units)
        
        return percent * height
        
    }
    
    
    
    
    
    func getData(value: CGFloat) -> String {
        
        
        let format = DateFormatter()
        format.dateFormat = "MM dd"
        
        let date = Date(timeIntervalSince1970: Double(value / 1000.0))
        
        return format.string(from: date)
        
    }
    
    
    
}


@main
struct MainWidget : Widget {
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: "Graph", provider: Provider()) { data in
            WidgetView(data: data)
        }
        .description(Text("Detail Status"))
        .configurationDisplayName(Text("Detail Updates"))
        .supportedFamilies([.systemLarge])
        
    }
    
    
}








func getData(completion: @escaping ([JSONModel]) -> ()) {
    
    let url = "https://canvasjs.com/data/gallery/javascript/daily-sales-data.json"
    let session = URLSession(configuration: .default)
    session.dataTask(with: URL(string: url)!) { (data, _, err) in
        
        if err != nil {
            
            print(err!.localizedDescription)
            return
            
        }
        
        do {
            
            let jsonData = try JSONDecoder().decode([JSONModel].self, from: data!)
            completion(jsonData)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }.resume()
    
}


//struct Graph_Previews: PreviewProvider {
//    static var previews: some View {
//        GraphEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}

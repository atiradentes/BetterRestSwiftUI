//
//  ContentView.swift
//  BetterRest
//
//  Created by Arthur Tiradentes on 17/10/23.
//

import CoreML
import SwiftUI


struct ContentView: View {
    @State private var horaAcordar = horaPadrao
    @State private var quantidadeSono = 8.0
    @State private var quantidadeCafe = 1
    
    
    static var horaPadrao: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var calculoSono: String {
        do {
            let config = MLModelConfiguration()
            let model = try calculadoraSono(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: horaAcordar)
            let hora = (components.hour ?? 0) * 60 * 60
            let minutos = (components.minute ?? 0) * 60
            
            let previsao = try model.prediction(wake: Int64(Double(hora + minutos)), estimatedSleep: quantidadeSono, coffee: Int64(Double(quantidadeCafe)))
            
            let horaDormir = horaAcordar - previsao.actualSleep
            return horaDormir.formatted(date: .omitted, time: .shortened)
            
            
        } catch {
            return "Desculpe, houve um erro ao calcular sua hora de dormir."
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                    Section {
                        Text ("Qual horário você deseja acordar?")
                            .font(.headline)
                        HStack {
                            Spacer()
                            DatePicker("Escolha a hora",
                                       selection: $horaAcordar,
                                       displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            Spacer()
                        }
                    }
                    
                    Section {
                        Text("Por quantas horas você quer dormir?")
                            .font(.headline)
                        
                        Stepper("\(quantidadeSono.formatted()) horas",
                                value: $quantidadeSono,
                                in: 3...14,
                                step: 0.5)
                    }
                    
                    Section {
                        Text("Você toma quantas xícaras de café por dia?")
                            .font(.headline)
                        
                        Stepper("\(quantidadeCafe)",
                                    value:$quantidadeCafe,
                                    in: 1...20)
                    }
                    
                Section {
                    VStack(alignment:.center) {
                        Text("Sua hora ideal para dormir é")
                        Text(calculoSono)
                            .font(.title)
                    }
                        .font(.headline.weight(.regular))
                        .frame(minWidth: 300)
                }
                
            }
                .navigationTitle("BetterRest")

        }
    }

}

#Preview {
    ContentView()
}

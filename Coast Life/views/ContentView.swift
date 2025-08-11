//
//  ContentView.swift
//  CoastLifeApp
//
//  Created by alan craig on 7/28/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

         
            AboutView()
                .tabItem {
                    Label("About", systemImage: "person.circle.fill")
                }
            
            
            MerchandiseView()
                .tabItem {
                    Label("Merchandise", systemImage: "storefront.circle.fill")
                }
            
            BookingView()
                .tabItem {
                    Label("Booking", systemImage: "calendar.circle.fill")
                }
          
           PartnerView()
                .tabItem {
                    Label("Partner", systemImage: "person.2.circle")
                }
        }
    }
}


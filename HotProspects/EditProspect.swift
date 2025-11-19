//
//  EditProspect.swift
//  HotProspects
//
//  Created by Mohsin khan on 19/11/2025.
//

import SwiftUI

struct EditProspect: View {
   @Bindable var prospect: Prospect
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack{
            List{
                TextField("Name" , text: $prospect.name)
                TextField("emailAddress" , text: $prospect.emailAddress)
            }
            .navigationTitle("Edit Prospect")
            
            .toolbar{
                Button("Save"){
                   dismiss()
                }
            }
        }
    }
}

#Preview {
    EditProspect(
        prospect: Prospect(
            name: "Preview User",
            emailAddress: "preview@example.com",
            isContacted: false
        )
    )
}

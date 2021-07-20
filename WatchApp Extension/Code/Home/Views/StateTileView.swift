//
//  StateTileView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 19.07.21.
//

import RoborockApi
import SwiftUI

struct StateTileView: View {
    @State var state: VacuumState
    @State var label: String

    var iconName: String {
        switch state {
        case .unknown:
            return "questionmark.circle" // 􀁜
        case .initiating:
            return "togglepower" // 􀥣
        case .sleeping:
            return "zzz" // 􀖃
        case .idle:
            return "powersleep" // 􀥦
        case .remoteControl:
            return "dot.arrowtriangles.up.right.down.left.circle" // 􀝯
        case .cleaning:
            return "leaf.arrow.triangle.circlepath" // 􀙜
        case .returningDock:
            return "arrow.uturn.backward.circle" // 􀱎
        case .manualMode:
            return "hand.tap" // 􀬁
        case .charging:
            return "bolt.fill" // 􀋦
        case .chargingError:
            return "bolt" //
        case .paused:
            return "pause.circle" // 􀊗
        case .spotCleaning:
            return "location.fill.viewfinder" // 􀮄
        case .inError:
            return "exclamationmark.circle" // 􀁞
        case .shuttingDown:
            return "power" // 􀆨
        case .updating:
            return "arrow.triangle.2.circlepath.circle" // 􀖊
        case .docking:
            return "location.viewfinder" // 􀮃
        case .goto:
            return "mappin.and.ellipse" // 􀎫
        case .zoneClean:
            return "square.split.bottomrightquarter" // 􀟻
        case .roomClean:
            return "rectangle.3.offgrid" // 􀇴
        case .fullyCharged:
            return "bolt.fill" // 􀋦
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
            }
            .background(Color.blue)
            .clipShape(Circle())

            Text(LocalizedStringKey(String("roborock.state.\(state.rawValue)")))
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("secondarySystemBackground"))
        .cornerRadius(22)
    }
}

struct StateTileView_Previews: PreviewProvider {
    static var previews: some View {
        StateTileView(state: VacuumState.charging, label: "Charging")
            .previewLayout(.fixed(width: 100, height: 100))
    }
}

//
//  StateTileView.swift
//  WatchApp Extension
//
//  Created by Thomas Hack on 19.07.21.
//

import RoborockApi
import SwiftUI

struct StateTileView: View {
    var status: StateAttribute.StatusStateAttribute

    var iconName: String {
        switch status.value {
        case .error:
            return "exclamationmark.circle" // 􀁞
        case .docked:
            return "bolt.fill" // 􀋦
        case .idle:
            return "powersleep" // 􀥦
        case .returning:
            return "arrow.uturn.backward.circle" // 􀱎
        case .cleaning:
            switch status.flag {
            case .zone:
                return "square.split.bottomrightquarter" // 􀟻
            case .segment:
                return "rectangle.3.offgrid" // 􀇴
            case .spot:
                return "mappin.and.ellipse" // 􀎫
            case .mapping:
                return "location.viewfinder" // 􀮃
            default:
                return "leaf.arrow.triangle.circlepath" // 􀙜
            }
        case .paused:
            switch status.flag {
            case .resumable:
                return "play.circle" // 􀊗
            default:
                return "pause.circle" // 􀊗
            }
        case .manualControl:
            return "dot.arrowtriangles.up.right.down.left.circle" // 􀝯
        case .moving:
            return "location.fill.viewfinder" // 􀮄
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .padding(6)
                .background(Color("blue-primary"))
                .clipShape(Circle())

            Text(LocalizedStringKey(String("roborock.state.value.\(status.value)")))
                .font(.system(size: 18, weight: .bold, design: .default))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct StateTileView_Previews: PreviewProvider {
    static var previews: some View {
        StateTileView(status: StateAttribute.StatusStateAttribute(value: .docked, flag: .none))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}

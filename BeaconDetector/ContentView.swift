//
//  ContentView.swift
//  BeaconDetector
//
//  Created by Matheus Pacheco Fusco on 17/06/19.
//  Copyright © 2019 Matheus Pacheco Fusco. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

class BeaconDetector: NSObject, BindableObject, CLLocationManagerDelegate {
    var didChange = PassthroughSubject<Void, Never>()
    var locationManager: CLLocationManager?
    var lastDistance = CLProximity.unknown
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    self.startScannig()
                }
            }
        }
    }
    
    private func startScannig() {
        guard let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5") else { return }
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
    func update(distance: CLProximity) {
        lastDistance = distance
        didChange.send(())
    }
}

struct BigText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72, design: .rounded))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct ContentView : View {
    @ObjectBinding var detector = BeaconDetector()
    
    var body: some View {
        if detector.lastDistance == .immediate {
            return Text("Right Here")
                .modifier(BigText())
                .background(Color.red)
                .edgesIgnoringSafeArea(.all)
        } else if detector.lastDistance == .near {
            return Text("Near")
                .modifier(BigText())
                .background(Color.orange)
                .edgesIgnoringSafeArea(.all)
        } else if detector.lastDistance == .far {
            return Text("Far")
                .modifier(BigText())
                .background(Color.blue)
                .edgesIgnoringSafeArea(.all)
        } else {
            return Text("Unknown")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

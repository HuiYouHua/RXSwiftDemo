//
//  RxUIApplicationDelegateProxy.swift
//  50DelegateProxy
//
//  Created by 华惠友 on 2020/11/17.
//  Copyright © 2020 com.development. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
 
//UIApplicationDelegate 代理委托
public class RxUIApplicationDelegateProxy :
    DelegateProxy<UIApplication, UIApplicationDelegate>,
    UIApplicationDelegate, DelegateProxyType {
     
    public weak private(set) var application: UIApplication?
     
    init(application: ParentObject) {
        self.application = application
        super.init(parentObject: application, delegateProxy: RxUIApplicationDelegateProxy.self)
    }
     
    public static func registerKnownImplementations() {
        self.register { RxUIApplicationDelegateProxy(application: $0) }
    }
     
    public static func currentDelegate(for object: UIApplication) -> UIApplicationDelegate? {
        return object.delegate
    }
     
    public static func setCurrentDelegate(_ delegate: UIApplicationDelegate?,
                                          to object: UIApplication) {
        object.delegate = delegate
    }
     
    override open func setForwardToDelegate(_ forwardToDelegate: UIApplicationDelegate?,
                                            retainDelegate: Bool) {
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: true)
    }
}

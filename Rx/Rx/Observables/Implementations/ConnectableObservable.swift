//
//  ConnectableObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Connection<SourceType, ResultType> : Disposable {
    typealias SelfType = Connection<SourceType, ResultType>
    
    var parent: ConnectableObservable<SourceType, ResultType>?
    var subscription: Disposable?
    
    init(parent: ConnectableObservable<SourceType, ResultType>, subscription: Disposable) {
        self.parent = parent
        self.subscription = subscription
    }
    
    func dispose() {
        if let parent = parent {
            parent.lock.performLocked {
                subscription!.dispose()
                subscription = nil
                self.parent = nil
            }
        }
    }
}

class ConnectableObservable<SourceType, ResultType> : ConnectableObservableType<ResultType> {
    typealias ConnectionType = Connection<SourceType, ResultType>
    
    let subject: SubjectType<SourceType, ResultType>
    let source: Observable<SourceType>
    
    var lock = Lock()
    var connection: ConnectionType?
    
    init(source: Observable<SourceType>, subject: SubjectType<SourceType, ResultType>) {
        self.source = asObservable(source)
        self.subject = subject
        self.connection = nil
    }
    
    override func connect() -> Result<Disposable> {
        return self.lock.calculateLocked { oldConnection in
            if let connection = connection {
                return success(connection)
            }
            else {
                return self.source.subscribeSafe(ObserverOf(self.subject)) >== { disposable in
                    self.connection = Connection(parent: self, subscription: disposable)
                    return success(self.connection!)
                }
            }
        }
    }
    
    override func subscribe(observer: ObserverOf<ResultType>) -> Result<Disposable> {
        return subject.subscribeSafe(observer)
    }
}
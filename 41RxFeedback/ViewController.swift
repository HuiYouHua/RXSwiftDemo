//
//  ViewController.swift
//  41RxFeedback
//
//  Created by 华惠友 on 2021/7/28.
//  Copyright © 2021 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback


class ViewController: UIViewController {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var minus: UIButton!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    let disposeBag = DisposeBag()
    
    //状态
    struct State {
        var id: Int //id数字
        var content: String //当前id对应的内容
    }

    ///事件
    enum Event {
        ///加一
        case increment
        ///减一
        case decrement
        //获取到内容
        case response(String)
    }
    struct Currying {
        func addCur(_ a: Int) -> (_ b: Float) -> (_ c: Double) -> Double {
            print("第一层: \(a)")
            return { (b: Float) -> (_ c: Double) -> Double in
                print("第二层: \(a): \(b)")
                return { (c: Double) -> Double in
                    print("第三层: \(a): \(b): \(c)")
                    print("\(Double(a)) + \(Double(b)) + \(Double(c)) = \(Double(a) + Double(b) + Double(c))")
                    return Double(a) + Double(b) + Double(c)
                }
            }
        }
        
        func react(request: @escaping (Int) -> Void,
                   effects: @escaping (Int) -> Void
        ) -> () -> Int {
            return {
                return 5
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let curry = Currying()
        
        let result = curry.react { a in
            
        } effects: { b in
            
        }()
        print(result)
        
        
        let a = Currying.addCur(curry)
        let b = a(10)
        let c = b(20)
        let d = c(30)
        print(d)
        
        print(a(10)(20)(30))
        

        let disposeBag = DisposeBag()
        
        
        /**
         RxFeedback 的核心内容为状态（State）、事件（Event）、反馈循环（Feedback Loop）：
         State：包含页面中各种需要的数据。我们可以用这些状态来控制页面内容的显示，或者触发另外一个事件。
         Event：用来描述所产生的事件。当发生某个事件时，更新当前状态。
         Feedback Loop：用来修改状态、IO 和资源管理的。比如我们可以将状态输出到 UI 页面上，或者将 UI 事件输入到反馈循环里面去。
         
         public static func system<State, Event>(
             initialState: State,
             reduce: @escaping (State, Event) -> State,
             scheduler: ImmediateSchedulerType,
             feedback: [Feedback<State, Event>]
         ) -> Observable<State> {
             return Observable<State>.deferred {
                 let replaySubject = ReplaySubject<State>.create(bufferSize: 1)

                 let asyncScheduler = scheduler.async

                 let events: Observable<Event> = Observable.merge(
                     feedback.map { feedback in
                         let state = ObservableSchedulerContext(source: replaySubject.asObservable(), scheduler: asyncScheduler)
                         return feedback(state)
                     }
                 )
                 // This is protection from accidental ignoring of scheduler so
                 // reentracy errors can be avoided
                 .observeOn(CurrentThreadScheduler.instance)

                 return events.scan(initialState, accumulator: reduce)
                     .do(
                         onNext: { output in
                             replaySubject.onNext(output)
                         }, onSubscribed: {
                             replaySubject.onNext(initialState)
                         }
                     )
                     .subscribeOn(scheduler)
                     .startWith(initialState)
                     .observeOn(scheduler)
             }
         }

         */
//        public typealias Signal<Element> = SharedSequence<SignalSharingStrategy, Element>

//        Driver.system(initialState: <#T##State#>, reduce: <#T##(State, Event) -> State#>, feedback: <#T##SharedSequence<DriverSharingStrategy, _>.Feedback<State, Event>...##SharedSequence<DriverSharingStrategy, _>.Feedback<State, Event>##(Driver<State>) -> Signal<Event>#>)
        Driver.system(
            initialState: State(id: 0, content: ""),
            reduce: { state, event in
                switch event {
                case .increment:
                    var result = state
                    result.id = result.id + 1
                    return result
                case .decrement:
                    var result = state
                    result.id = result.id - 1
                    return result
                case .response(let content):
                    var result = state
                    result.content = content
                    return result
                }
            },
            feedback:
                //UI反馈
                bind(self) { me, state in
                    //状态输出到页面控件上
                    let subscriptions = [
                        state.map{ "\($0.id)" }.drive(me.label!.rx.text),
                        state.map{ "\($0.content)" }.drive(me.textView!.rx.text)
                    ]
                    //将 UI 事件变成Event输入到反馈循环里面去
                    let events = [
                        me.plus!.rx.tap.map { Event.increment },
                        me.minus!.rx.tap.map { Event.decrement }
                    ]
                    return Bindings(subscriptions: subscriptions, events: events)
                },
                //非UI的自动反馈
                react(request: { $0.id }, effects: { id  in
                    return self.getContent(id: id)
                        .asSignal(onErrorRecover: { _ in .empty() })
                        .map(Event.response)
                })
        )
        .drive()
        .disposed(by: disposeBag)
    }

    //根据id获取对应数据
        func getContent(id: Int) -> Observable<String> {
            print("正在请求数据......")
            let observable = Observable.just("这个是 id=\(id) 的新闻内容......")
            //延迟1秒模拟网络请求
            return observable.delay(1, scheduler: MainScheduler.instance)
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    @IBAction func mvvmAction(_ sender: Any) {
        self.present(MVVMController(), animated: true, completion: nil)
    }
    
    @IBAction func feedbackAction(_ sender: Any) {
        self.present(FeedbackController(), animated: true, completion: nil)
    }
    
    @IBAction func reactorkitAction(_ sender: Any) {
        self.present(ReactorKitController(), animated: true, completion: nil)
    }
}


//
//  ViewController.swift
//  PlayingCard
//
//  Created by Stanislav on 06.03.2019.
//  Copyright © 2019 Stanislav Kozlov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    @IBOutlet weak var playingCardView: PlayingCardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction = [.left, .right]
            playingCardView.addGestureRecognizer(swipe)
            
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale))
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    
//    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
//        switch sender.state {
//        case .ended:
//            playingCardView.isFaceUp = !playingCardView.isFaceUp
//        default:
//            break
//        }
//
//    }
    
    
    @objc func nextCard() {
        if let card  = deck.draw() {
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //generate 12 random cards from deck
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2) {
            let card =  deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card  = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden}
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chooseCardView =  recognizer.view as? PlayingCardView {
                UIView.transition(with: chooseCardView,
                                  duration: 0.6,
                                  options: [.transitionFlipFromLeft],
                                  animations: {chooseCardView.isFaceUp = !chooseCardView.isFaceUp },
                                  completion: { finished in
                                    if self.faceUpCardViewsMatch {
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.6,
                                            delay: 0,
                                            options: [],
                                            animations: { self.faceUpCardViews.forEach({
                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                            }) },
                                            completion: {position in
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 0.75,
                                                    delay: 0.6,
                                                    options: [],
                                                    animations: { self.faceUpCardViews.forEach({
                                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                        $0.alpha = 0.0
                                                    }) },
                                                    completion: {position in
                                                        self.faceUpCardViews.forEach {
                                                            $0.isHidden = true
                                                            $0.alpha = 1
                                                            $0.transform = .identity
                                                        }
                                                }
                                                )
                                                
                                        })
                                    } else {
                                        //flip all cards if open 2 cards
                                        if self.faceUpCardViews.count == 2 {
                                            self.faceUpCardViews.forEach {cardView in
                                                UIView.transition(
                                                    with: cardView,
                                                    duration: 0.6,
                                                    options: [.transitionFlipFromLeft],
                                                    animations: {cardView.isFaceUp = false },
                                                    completion: nil)}
                                        }
                                    }
                                    
                })
            }
        default:
            break
        }
    }

}


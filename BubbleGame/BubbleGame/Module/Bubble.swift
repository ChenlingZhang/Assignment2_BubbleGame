//
//  Bubble.swift
//  BubbleGame
//
//  Created by Chenling Zhang on 19/4/2023.
//

import Foundation
import UIKit

class Bubble: UIButton {
    var value: Int = 0
    var UIScreenWidth = UIScreen.main.bounds.width
    var UIScreenHeight = UIScreen.main.bounds.height
    var radius:UInt32 {
        return UInt32(UIScreenWidth / 10)
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
        self.backgroundColor = bubbleValueSet().backgroundColor
        self.value = bubbleValueSet().value
        self.frame = bubbleFrameSet()
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
    }
    
    // This function used to init bubble frame
    func bubbleFrameSet() ->CGRect{
        let bubble_size = CGFloat(2 * radius)
        let bubble_x_position = CGFloat(10 + UInt32.random(in: 0...UInt32((UIScreenWidth - bubble_size))))
        let bubble_y_position = CGFloat(10 + UInt32.random(in: 150...UInt32((UIScreenHeight - bubble_size))))
        
        return CGRect(x: bubble_x_position, y: bubble_y_position, width: bubble_size, height: bubble_size)
    }
    
    // This function used to set bubbles' background color and values
    func bubbleValueSet() -> BubbleStruct{
        let possiblility = Int.random(in: 0...100)
        var bubbleStruct = BubbleStruct(backgroundColor: .clear, value: 0)
        
        switch possiblility{
        case 0...39:
            bubbleStruct.backgroundColor = .red
            bubbleStruct.value = 1
        case 40...69:
            bubbleStruct.backgroundColor = .systemPink
            bubbleStruct.value = 2
        case 70...85:
            bubbleStruct.backgroundColor = .green
            bubbleStruct.value = 5
        case 86...94:
            bubbleStruct.backgroundColor = .blue
            bubbleStruct.value = 8
        case 95...100:
            bubbleStruct.backgroundColor = .black
            bubbleStruct.value = 10
        default:
            print("An error occur when generate bubble color with possibility")
        }
        return bubbleStruct
    }
    
    // This function used to determin the animation when bubble appear
    func animation(){
        let bubbleAnimation = CABasicAnimation(keyPath: "opacity")
        bubbleAnimation.duration = 0.5
        bubbleAnimation.fromValue = 0
        bubbleAnimation.toValue = 1
        
        layer.add(bubbleAnimation, forKey: nil)
    }
}

struct BubbleStruct{
    var backgroundColor: UIColor
    var value: Int
}

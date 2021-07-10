//
//  GameScene.swift
//  2d game demo
//
//  Created by 林子轩 on 2021/7/8.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	// Nodes
	var player: SKNode?
	var joystick: SKNode?
	var knob: SKNode?
	var arrow: SKNode?
	var button: SKNode?
	
	// Booleans
	var joystickAction = false
	var shootingState = false
	
	// Measure
	var knobRadius : CGFloat = 50.0
	
	// Sprite Engine
	var prevY : CGFloat = 0.0
	var prevTimeInterval : TimeInterval = 0
	var facingRight = true
	var playerSpeed = 8.0
	
	override func didMove(to view: SKView) {
		player = childNode(withName: "alien")
		joystick = childNode(withName: "joystick")
		knob = joystick?.childNode(withName: "knob")
		arrow = player?.childNode(withName: "arrow")
		button = childNode(withName: "button")
		arrow?.isHidden = true
	}
	
}

// Touches
extension GameScene {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			if let knob = knob {
				let location = touch.location(in: joystick!)
				joystickAction = knob.frame.contains(location)
			}
			
			if let button = button {
				if button.contains(touch.location(in: self)) {
					shootingState = !shootingState
				}
				arrow?.isHidden = !shootingState
			}
				
			if shootingState && touch.location(in: self).x > 400 {
				prevY = touch.location(in: self).y
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let joystick = joystick else {return}
		guard let knob = knob else {return}
		
		if !joystickAction && !shootingState {re#imageLiteral(resourceName: "simulator_screenshot_8A0461B6-C3EE-4F92-89DB-AD2C7EF2178B.png")turn}
		
		for touch in touches {
			if shootingState && touch.location(in: self).x > 400 {
				let posY = touch.location(in: self).y
				if posY > prevY {
					let arrowAction = SKAction.scaleY(to: arrow!.yScale + 1, duration: 0.1)
					arrow?.run(arrowAction)
				} else if posY < prevY {
					let arrowAction = SKAction.scaleY(to: arrow!.yScale - 1, duration: 0.1)
					arrow?.run(arrowAction)
				}
				prevY = posY
			} else {
				let pos = touch.location(in: joystick)
				
				let length = sqrt(pow(pos.x, 2) + pow(pos.y, 2))
				let angle = atan2(pos.y, pos.x)
				
				if knobRadius > length {
					knob.position = pos
				} else {
					knob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
				}
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let xJoystickCoordinate = touch.location(in: joystick!).x
			let xLimit : CGFloat = 200.0
			if !shootingState && xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
				resetKnobPos()
			}
		}
	}
}

// Actions
extension GameScene {
	func resetKnobPos () {
		let initialPoint = CGPoint(x: 0, y: 0)
		let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
		moveBack.timingMode = .linear
		knob?.run(moveBack)
		joystickAction = false
	}
}

// Game Loop
extension GameScene {
	override func update(_ currentTime: TimeInterval) {
		let deltaTime = currentTime - prevTimeInterval
		prevTimeInterval = currentTime
		
		// player movement
		if shootingState {
			arrow?.isHidden = false
			guard let knob = knob else {return}
			let xPos = Double(knob.position.x)
			let yPos = Double(knob.position.y)
			let angle = atan2(yPos, xPos) - .pi/2
			let arrowAction = SKAction.rotate(toAngle: CGFloat(angle), duration: 0.1)
			arrow?.run(arrowAction)
		} else {
			guard let knob = knob else {return}
			let xPos = Double(knob.position.x)
			let displacement = CGVector(dx: deltaTime * xPos * playerSpeed, dy: 0)
			let move = SKAction.move(by: displacement, duration: 0)
			let faceAction : SKAction!
			let movingRight = xPos >= 0
			if (movingRight != facingRight) {
				facingRight = movingRight
				let faceMovement = SKAction.scaleX(to: (facingRight == true) ? 1:-1, duration: 0.1)
				faceAction = SKAction.sequence([move, faceMovement])
			} else {
				faceAction = move
			}
			player?.run(faceAction)
		}
	}
}

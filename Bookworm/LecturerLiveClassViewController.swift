//
//  LecturerLiveClassViewController.swift
//  Bookworm
//
//  Created by Rajesh Raman on 17/2/18.
//  Copyright © 2018 DeedsIT. All rights reserved.
//

import Foundation
import UIKit
import Charts
import SwiftyBeaver

class LecturerLiveClassViewController : UIViewController{
    @IBOutlet weak var classStatusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var disLikesLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var chartView: LineChartView!
    var ratings = [Int]()
    
    var timer = Timer()
    var mockDatatimer = Timer()
    var seconds = 0
    
    var isPlaying = true
    
    let green = UIColor(red:0, green:0.54, blue:0.48, alpha:1)
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            timer.invalidate()
            mockDatatimer.invalidate()
            isPlaying = !isPlaying
            playPauseButton.setTitle("P", for: .normal)
        }else{
            runTimer()
            createMockData()
            isPlaying = !isPlaying
            playPauseButton.setTitle("S", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpClassStatusLabel()
        setUpTimerLabel()
        setUpPlayPauseButton()
    }
    
    fileprivate func setUpClassStatusLabel(){
        
    }
    
    fileprivate func setUpTimerLabel(){
        runTimer()
        createMockData()
    }
    
    fileprivate func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(LecturerLiveClassViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func updateTimer(){
        seconds += 1
        timerLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        if hours > 0{
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }else{
            return String(format:"%02i:%02i", minutes, seconds)
        }
    }
    
    fileprivate func setUpPlayPauseButton(){
        playPauseButton.frame = CGRect(x: 160, y: 100, width: 64, height: 64)
        playPauseButton.clipsToBounds = true
        playPauseButton.layer.cornerRadius = playPauseButton.bounds.size.width/2
        playPauseButton.setTitle("S", for: .normal)
        
    }
    
    /** Chart **/
    
    func updateGraph(){
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<ratings.count {
            let value = ChartDataEntry(x: Double(i), y: Double(ratings[i]))
            lineChartEntry.append(value)
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Rating")
        line1.colors = [NSUIColor.blue]
        line1.mode = .cubicBezier
        line1.fillAlpha = 0.8
        line1.fill = Fill(CGColor: green.cgColor)
        line1.drawFilledEnabled = true
        
        let data = LineChartData()
        data.addDataSet(line1)
        
        chartView.data = data
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.gridColor = .clear
        chartView.updateFocusIfNeeded()
        
    }
    
    
    /** Mock graph data **/
    func delay(delay:UInt32, closure:()->()) {
        sleep(delay)
        closure()
    }
    
    fileprivate func createMockData(){
        
        mockDatatimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(LecturerLiveClassViewController.generateMockRating)), userInfo: nil, repeats: true)
    }
    
    @objc func generateMockRating(){
        
        self.delay(delay: 1, closure: {
            let randomNumber = Int(arc4random_uniform(4))
            SwiftyBeaver.debug("randomNumber = \(randomNumber)")
            ratings.append(randomNumber)
            updateGraph()
        })
    }
}


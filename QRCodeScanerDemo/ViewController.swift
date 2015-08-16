//
//  ViewController.swift
//  QRCodeScanerDemo
//
//  Created by qingjiezhao on 6/11/15.
//  Copyright (c) 2015 qingjiezhao. All rights reserved.
//

import UIKit
import AVFoundation

//http://quickmark.com.tw/En/qrcode-datamatrix-generator/default.asp?qrLink

class ViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var output: UILabel!
    
    var device : AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    lazy var deviceInput : AVCaptureDeviceInput = {
        return AVCaptureDeviceInput(device: self.device, error: nil)
    }()
    
    var metadataOutput : AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    var session : AVCaptureSession = AVCaptureSession()
    
    lazy var previewLayer : AVCaptureVideoPreviewLayer = {
        return AVCaptureVideoPreviewLayer(session: self.session)
    }()
    
    var targetLayer = CALayer()
    var codeObjects = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.addOutput(metadataOutput)
        session.addInput(deviceInput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
        targetLayer.frame = view.bounds
        view.layer.addSublayer(targetLayer)
        session.startRunning()
        
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        codeObjects.removeAllObjects()
        clearTargetLayer()
        
        for current in metadataObjects{
            if var readableCodeObject = current as? AVMetadataMachineReadableCodeObject{
                readableCodeObject = previewLayer.transformedMetadataObjectForMetadataObject(readableCodeObject) as! AVMetadataMachineReadableCodeObject
                showDetectedObjects(readableCodeObject)
                output.text = readableCodeObject.stringValue
            }
        }
    }
    
    func showDetectedObjects(codeObject : AVMetadataMachineReadableCodeObject){
        var shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.greenColor().CGColor
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.3).CGColor
        var path = createPathForPoints(codeObject.corners)
        shapeLayer.path = path
        targetLayer.addSublayer(shapeLayer)
    }
    
    func clearTargetLayer(){
        if targetLayer.sublayers != nil {
            var sublayers : NSArray = targetLayer.sublayers
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func createPathForPoints(points:NSArray) -> CGMutablePathRef{
        let path = CGPathCreateMutable()
        var point = CGPoint()
        
        if points.count > 0 {
            (points.objectAtIndex(0) as! CFDictionaryRef,&point)
            CGPathMoveToPoint(path, nil, point.x, point.y)
            
            var i = 1
            while i < points.count{
                CGPointMakeWithDictionaryRepresentation(points.objectAtIndex(i) as! CFDictionaryRef, &point)
                CGPathAddLineToPoint(path, nil, point.x, point.y)
                i++
            }
            CGPathCloseSubpath(path)
        }
        return path
    }
    
    @IBAction func btnLight(sender: AnyObject) {
        toggleFlash()
    }
    
    func toggleFlash(){
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            device.lockForConfiguration(nil)
            if (device.torchMode == AVCaptureTorchMode.On) {
                device.torchMode = AVCaptureTorchMode.Off
            } else {
                device.setTorchModeOnWithLevel(1.0, error: nil)
            }
            device.unlockForConfiguration()
        }
    }
    
    
}

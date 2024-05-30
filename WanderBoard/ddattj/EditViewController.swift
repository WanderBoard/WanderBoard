//
//  EditViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit

class EditViewController: MyPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func configureUI() {
        // 여기에 수정할 내용을 보여주는 UI를 구성
        let textField = UITextField()
//        textField.placeholder = MyPageViewController.myName.text
        view.addSubview(textField)
        
        // 수정 버튼
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("저장", for: .normal)
        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    @objc func saveChanges() {
        // 여기에 수정 내용을 저장하는 작업을 구현
        // 예를 들어, 텍스트 필드에서 입력한 내용을 가져와서 저장하는 코드를 작성
    }
    

}

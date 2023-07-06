//
//  ToDoListViewControllerDelegate.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 30.06.2023.
//

import UIKit


protocol ToDoListViewControllerDelegate: AnyObject {
    func setupHeader()
    func setupUI()
    func setupTableViewCells()
    func setupCreationButton()
    func setupConstraints()
}

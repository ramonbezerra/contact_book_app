import 'dart:io';

import 'package:contact_book_app/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact}); // optional parameter

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) 
      _editedContact = Contact();
    else
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(_editedContact.name ?? "Novo Contato"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_editedContact.name != null && _editedContact.name.isNotEmpty)
            Navigator.pop(context, _editedContact);            
          else
            FocusScope.of(context).requestFocus(_nameFocus);
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _editedContact.image != null ? 
                      FileImage(File(_editedContact.image)) :
                        AssetImage("images/person.png")
                  )
                ),
              ),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Nome"),
              focusNode: _nameFocus,
              controller: _nameController,
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editedContact.name = text;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: "E-mail"),
              controller: _emailController,
              onChanged: (text) {
                _userEdited = true;
                _editedContact.email = text;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Phone"),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (text) {
                _userEdited = true;
                _editedContact.phone = text;
              },
            ),
          ],
        ),
      ),
    ));
  }

  Future<bool> _requestPop() {
    if(_userEdited){
      showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar Alterações?"),
            content: Text("Se você sair, suas alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sair"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );
      return Future.value(false); 
    } else
      return Future.value(true);
  }
}
import 'dart:io';

import 'package:contact_book_app/helpers/contact_helper.dart';
import 'package:contact_book_app/ui/contact_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red,
        icon: Icon(Icons.add),
        label: Text("Novo Contato")
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        }
      )
    );
  }

  Widget _contactCard(context, index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].image != null ? 
                      FileImage(File(contacts[index].image)) :
                        AssetImage("images/person.png")
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text(contacts[index].name ?? "", 
                      style: TextStyle(fontSize: 22.0,
                              fontWeight: FontWeight.bold)
                    ),
                    Text(contacts[index].email ?? "", 
                      style: TextStyle(fontSize: 18.0,
                              fontWeight: FontWeight.bold)
                    ),
                    Text(contacts[index].phone ?? "", 
                      style: TextStyle(fontSize: 18.0,
                              fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showContactPage({contact}) async {
    final recContact = await Navigator.push(context, 
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact))
    );

    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();        
    } 
  }

  void _showOptions(context, index) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: () {

                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Excluir Contato"),
                              content: Text("Deseja realmente excluir o contato ${contacts[index].name}?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Não"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text("Sim"),
                                  onPressed: () {
                                    helper.deleteContact(contacts[index].id);
                                    setState(() {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      contacts.removeAt(index);
                                    });
                                  },
                                )
                              ]
                            );
                          }
                        );
                        
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _getAllContacts() {
    helper.getContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}
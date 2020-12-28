import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newapp/widget/chart.dart';
import 'package:newapp/widget/newtrans.dart';
import './models/transactions.dart';
import './widget/transaction_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.lightGreenAccent,
        errorColor: Colors.lightGreenAccent,
        fontFamily: 'Ouicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
            headline6: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            button: TextStyle(color: Colors.white)),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //String titleinp;
  //String amtinp;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _usertransactions = [
    //Transaction(id: 't1', title: 'Shoes', amount: 2000, date: DateTime.now()),
    //Transaction(id: 't2', title: 'Shirt', amount: 1000, date: DateTime.now())
  ];

  List<Transaction> get _recentTransaction {
    return _usertransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(
        days: 7,
      )));
    }).toList();
  }

  void _addtransaction(String title, double amount, DateTime chosenDate) {
    final newtx = Transaction(
        title: title,
        amount: amount,
        date: chosenDate,
        id: DateTime.now().toString());
    setState(() {
      _usertransactions.add(newtx);
    });
  }

  void _startAddNewTrans(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return NewTransaction(_addtransaction);
        });
  }

  void _delTrans(String id) {
    setState(() {
      _usertransactions.removeWhere((element) => element.id == id);
    });
  }

  bool _showc = false;

  @override
  Widget build(BuildContext context) {
    final isLandscape =MediaQuery.of(context).orientation == Orientation.landscape;
    final PreferredSizeWidget appbar =Platform.isIOS? CupertinoNavigationBar(
      middle: Text('Personal Expenses'),
      trailing: Row( mainAxisSize: MainAxisSize.min,
        children: <Widget>[GestureDetector(child:Icon(CupertinoIcons.add), onTap:  () {
            _startAddNewTrans(context);
          },)],
      )   
    ) :AppBar(
      title: Text('Personal Expenses'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () {
            _startAddNewTrans(context);
          },
        )
      ],
    );

    final txlst = Container(
        height: (MediaQuery.of(context).size.height -
                appbar.preferredSize.height -
                MediaQuery.of(context).padding.top) *
            0.7,
        child: TransactionList(_usertransactions, _delTrans));

    final pageBody=SafeArea(child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            /*Container(
              width: double.infinity,
              child: Card(
                color: Colors.blue[100],
                child: Text('CHART!!'),
                elevation: 6,
              ),
            ),*/
            if(isLandscape)Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Show Chart' ,style:Theme.of(context).textTheme.headline6),
                  Switch.adaptive(
                      value: _showc,
                      onChanged: (val) {
                        setState(() {
                          _showc = val;
                        });
                      })
                ],
              ),
            if (!isLandscape)
              Container(
                  height: (MediaQuery.of(context).size.height -
                          appbar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      0.3,
                  child: Chart(_recentTransaction)),
            if (!isLandscape) txlst,
            if (isLandscape)
              _showc
                  ? Container(
                      height: (MediaQuery.of(context).size.height -
                              appbar.preferredSize.height -
                              MediaQuery.of(context).padding.top) *
                          0.7,
                      child: Chart(_recentTransaction))
                  : txlst,
          ],
        ),
      ),);

    
    return Platform.isIOS?CupertinoPageScaffold(child: pageBody,navigationBar:appbar) :Scaffold(
      appBar: appbar,
      body:pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:Platform.isIOS?Container(): FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTrans(context),
      ),
    );
  }
}

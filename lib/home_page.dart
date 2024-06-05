import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fromCurrency = 'USD';
  String toCurrency = 'IDR';
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];

  @override
  void initState() {
    super.initState();
    _getCurrencies();
  }

  Future<void> _getCurrencies() async {
    var response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));

    var data = json.decode(response.body);
    setState(() {
      currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
      rate = data['rates'][toCurrency];
    });
  }

  Future<void> _getRate() async {
    var response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));

    var data = json.decode(response.body);
    setState(() {
      rate = data['rates'][toCurrency];
    });
  }

  void _swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      _getRate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 20),
              const Center(
                child: Text(
                  'Currency Converter',
                  style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Image.asset('assets/images/money_exchange.png',
                    width: MediaQuery.of(context).size.width / 2),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                  decoration: InputDecoration(
                      label: const Text('Amount'),
                      floatingLabelStyle: TextStyle(
                          color: amountController.text.isNotEmpty
                              ? Colors.greenAccent
                              : Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.greenAccent),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
                  onChanged: (value) {
                    if (value != '') {
                      setState(() {
                        double amount = double.parse(value);
                        total = amount * rate;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 100,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white, // Warna latar belakang container
                        borderRadius: BorderRadius.circular(
                            10.0), // Radius sudut container
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: fromCurrency,
                          isExpanded: true,
                          menuMaxHeight: 400,
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor: Colors.greenAccent,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          items: currencies.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(
                              () {
                                fromCurrency = newValue!;
                                _getRate();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      // onPressed = _swapCurrencies
                      onPressed: _swapCurrencies,
                      icon: const Icon(
                        Icons.swap_horiz,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 100,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white, // Warna latar belakang container
                        borderRadius: BorderRadius.circular(
                            10.0), // Radius sudut container
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: toCurrency,
                          menuMaxHeight: 400,
                          borderRadius: BorderRadius.circular(15),
                          isExpanded: true,
                          dropdownColor: Colors.greenAccent,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          items: currencies.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(
                              () {
                                toCurrency = newValue!;
                                _getRate();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rate $rate',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                total.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

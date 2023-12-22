import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PhonePePayment extends StatefulWidget {
  const PhonePePayment({super.key});

  @override
  State<PhonePePayment> createState() => _PhonePePaymentState();
}

class _PhonePePaymentState extends State<PhonePePayment> {
  // ---------------- VALUES ---------------

  String enviroment = "UAT_SIM";
  String appId = "12";
  String merchangID = "PGTESTPAYUAT";
  bool enableLoggin = true;

  String checksum = "";
  String saltkey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  String saltIndex = "1";

  String callBackURL =
      "https://webhook.site/f63d1195-f001-474d-acaa-f7bc4f3b20b1";

  String body = "";
  Object? result;

  // -------------.\-/VALUES\-/.------------

  // ------------- END POINTS --------------
  String apiEndPoint = "/pg/v1/pay";

  // ---------------------------------------

  // -------------.\-/ INITIALIZE BODY\-/.------------

  getCheckSum() {
    final requestData = {
      "merchantId": "$merchangID",
      "merchantTransactionId": "transaction_123",
      "merchantUserId": "90223250",
      "amount": 1000,
      "mobileNumber": "9999999999",
      "callbackUrl": "$callBackURL",
      "paymentInstrument": {
        "type": "PAY_PAGE",
        // "targetApp": "com.phonepe.app"
      },
      // "deviceContext": {"deviceOS": "ANDROID"}
    };

    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));
    checksum =
        '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltkey)).toString()}###$saltIndex';

    return base64Body;
  }

  // ----------.\-/ DONE INITIALIZE BODY\-/.----------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    body = getCheckSum().toString();
    initPhonePe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PHONEPE PAYMENT GATWAY"),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
            child: Text("PAY"),
            onPressed: () {
              startPgTransaction();
            },
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "RESULT",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(result.toString()),
        ],
      )),
    );
  }

  void initPhonePe() {
    PhonePePaymentSdk.init(enviroment, appId, merchangID, enableLoggin)
        .then((val) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void startPgTransaction() async {
    try {
      var response = PhonePePaymentSdk.startPGTransaction(
          body, callBackURL, checksum, {}, apiEndPoint, "");
      response
          .then((val) => {
                setState(() {
                  if (val != null) {
                    String status = val['status'].toString();
                    String error = val['error'].toString();

                    if (status == 'SUCCESS') {
                      result = "FLOW COMPLETE - STATUS: SUCCESS";
                    } else {
                      result =
                          "FLOW COMPLETE - STATUS: $status & ERROR : $error";
                    }
                  } else {
                    result = "Flow incomplete";
                  }
                })
              })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }

  void handleError(error) {
    setState(() {
      result = {"error": error};
    });
  }
}

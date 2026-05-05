// Production-grade pdf_screen.dart
// Matches Arena and Nexa quotation preview layouts based on showroomType
// Replace your existing file with this implementation.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QuoteData {
  final String showroomType;
  final String customerName;
  final String contactNo;
  final String email;
  final String city;
  final String professionType;
  final String corporateName;
  final String departmentName;
  final String rmName;
  final String rmPhone;
  final String srmName;
  final String srmPhone;
  final String quotationDate;
  final String modelWithFuel;
  final String variant;
  final String color;
  final String customerFinancierType;
  final double exShowroom;
  final double insurance;
  final double ewCcpAmount;
  final double mgaOrGna;
  final double rtoAmount;
  final double fasTag;
  final double hpnCharges;
  final double tcsPct;
  final double mcdParking;
  final double corporateOffer;
  final double consumerOffer;
  final double exchangeOffer;
  final double addnlDiscount;
  final String financeOn;
  final double loanAmount;
  final double roi;
  final int tenureYears;
  final double emiAmount;
  final String locationAddress;
  final String locationCity;
  final String locationPincode;
  final String contactPhone;
  final String locationEmail;
  final String bankName;
  final String beneficiary;
  final String accountNumber;
  final String ifscCode;
  final String branchName;

  QuoteData({
    required this.showroomType,
    required this.customerName,
    required this.contactNo,
    required this.email,
    required this.city,
    required this.professionType,
    required this.corporateName,
    required this.departmentName,
    required this.rmName,
    required this.rmPhone,
    required this.srmName,
    required this.srmPhone,
    required this.quotationDate,
    required this.modelWithFuel,
    required this.variant,
    required this.color,
    required this.customerFinancierType,
    required this.exShowroom,
    required this.insurance,
    required this.ewCcpAmount,
    required this.mgaOrGna,
    required this.rtoAmount,
    required this.fasTag,
    required this.hpnCharges,
    required this.tcsPct,
    required this.mcdParking,
    required this.corporateOffer,
    required this.consumerOffer,
    required this.exchangeOffer,
    required this.addnlDiscount,
    required this.financeOn,
    required this.loanAmount,
    required this.roi,
    required this.tenureYears,
    required this.emiAmount,
    required this.locationAddress,
    required this.locationCity,
    required this.locationPincode,
    required this.contactPhone,
    required this.locationEmail,
    required this.bankName,
    required this.beneficiary,
    required this.accountNumber,
    required this.ifscCode,
    required this.branchName,
  });

  double get onRoadWithoutOffers =>
      exShowroom +
      insurance +
      ewCcpAmount +
      mgaOrGna +
      rtoAmount +
      fasTag +
      hpnCharges +
      tcsPct +
      mcdParking;

  double get totalOffers =>
      corporateOffer + consumerOffer + exchangeOffer + addnlDiscount;

  double get onRoadAfterOffers => onRoadWithoutOffers - totalOffers;
}

Future<void> generatePdf(QuoteData data) async {
  final pdf = pw.Document();

  final premLogo = await imageFromAssetBundle('assets/images/logo.png');
  final footerBanner = await imageFromAssetBundle(
    data.showroomType == 'Nexa'
        ? 'assets/images/logo.png'
        : 'assets/images/Arenabottom.png',
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(14),
      build: (_) => data.showroomType == 'Nexa'
          ? _buildNexaPage(data, premLogo, footerBanner)
          : _buildArenaPage(data, premLogo, footerBanner),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) => pdf.save());
}

pw.Widget _buildArenaPage(
    QuoteData d, pw.ImageProvider logo, pw.ImageProvider footer) {
  const yellow = PdfColor.fromInt(0xFFF7D500);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _arenaHeader(d, logo),
      _customerSection(d, yellow, isNexa: false),
      _vehicleSection(d),
      _priceSection(d, yellow, labelMga: 'MSGA'),
      _emiSection(d),
      _termsSection(),
      _bankSection(d),
      pw.Spacer(),
      pw.Image(footer, fit: pw.BoxFit.fill),
    ],
  );
}

pw.Widget _buildNexaPage(
    QuoteData d, pw.ImageProvider logo, pw.ImageProvider footer) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _nexaHeader(d, logo),
      _customerSection(d, PdfColors.grey300, isNexa: true),
      _vehicleSection(d),
      _priceSection(d, PdfColors.black, labelMga: 'GNA'),
      _emiSection(d),
      _termsSection(),
      _bankSection(d),
      pw.Spacer(),
      pw.Image(footer, fit: pw.BoxFit.fill),
    ],
  );
}

pw.Widget _arenaHeader(QuoteData d, pw.ImageProvider logo) => pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(children: [
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('MARUTI SUZUKI ARENA',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Image(logo, width: 90),
            ]),
        pw.SizedBox(height: 8),
        _dealerBlock(d),
      ]),
    );

pw.Widget _nexaHeader(QuoteData d, pw.ImageProvider logo) => pw.Container(
      color: PdfColors.black,
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(children: [
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logo, width: 100),
              pw.Text('N E X A',
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 4)),
            ]),
        pw.SizedBox(height: 8),
        _dealerBlock(d, white: true),
      ]),
    );

pw.Widget _dealerBlock(QuoteData d, {bool white = false}) {
  final color = white ? PdfColors.white : PdfColors.black;
  return pw.Column(children: [
    pw.Text('PREM MOTORS PVT. LTD.',
        style: pw.TextStyle(
            color: color, fontSize: 18, fontWeight: pw.FontWeight.bold)),
    pw.Text('(Authorised Maruti Suzuki Dealer)',
        style: pw.TextStyle(color: color, fontSize: 9)),
    pw.Text('Location Address : ${d.locationAddress}',
        style: pw.TextStyle(color: color, fontSize: 8)),
    pw.Text(
        'City: ${d.locationCity}, Rajasthan Pincode : ${d.locationPincode}',
        style: pw.TextStyle(color: color, fontSize: 8)),
    pw.Text('Contact No : ${d.contactPhone} Email : ${d.locationEmail}',
        style: pw.TextStyle(color: color, fontSize: 8)),
    pw.Text('Website: www.premmotors.com',
        style: pw.TextStyle(color: PdfColors.blue, fontSize: 8)),
  ]);
}

pw.Widget _customerSection(QuoteData d, PdfColor highlight,
    {required bool isNexa}) {
  return pw.Column(children: [
    pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _row('Customer Name: ${d.customerName}',
            'Quotation Date: ${d.quotationDate}'),
        _row('Contact No: ${d.contactNo}', 'Email: ${d.email}'),
        _row('City: ${d.city}', 'Profession Type: ${d.professionType}'),
        _row('Corporate Name: ${d.corporateName}',
            'Department Name: ${d.departmentName}'),
      ],
    ),
    pw.Container(
      color: highlight,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('RM (M.): ${d.rmName} (${d.rmPhone})'),
            pw.Text('SRM (M.): ${d.srmName} (${d.srmPhone})'),
          ]),
    ),
    pw.Center(
        child: pw.Text('PERFORMA INVOICE',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
  ]);
}

pw.Widget _vehicleSection(QuoteData d) => pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _row('Model With Fuel: ${d.modelWithFuel}', 'Variant: ${d.variant}'),
        _row('Color: ${d.color}',
            'Customer/Financier Type: ${d.customerFinancierType}'),
      ],
    );

pw.Widget _priceSection(QuoteData d, PdfColor highlight,
    {required String labelMga}) {
  return pw.Column(children: [
    pw.Center(
        child: pw.Text('PRICE BREAK-UP',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
    pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _priceRow('Ex-Showroom Price:', d.exShowroom),
        _priceRow('Insurance:', d.insurance),
        _priceRow('EW + CCP Platinum (2Yr.):', d.ewCcpAmount),
        _priceRow('$labelMga:', d.mgaOrGna),
        _priceRow('Registration/TRC:', d.rtoAmount),
        _priceRow('FASTag:', d.fasTag),
        _priceRow('HPN Charges:', d.hpnCharges),
        _priceRow('1% TCS:', d.tcsPct),
        _priceRow('MCD Parking:', d.mcdParking),
        _highlightPriceRow(
            'On Road Price Without Offers:', d.onRoadWithoutOffers, highlight),
        _priceRow('Corporate Offer:', d.corporateOffer),
        _priceRow('Consumer Offer:', d.consumerOffer),
        _priceRow('Exchange Offer:', d.exchangeOffer),
        _priceRow('Addnl. Discount:', d.addnlDiscount),
        _highlightPriceRow('On Road Price After Applicable Offers:',
            d.onRoadAfterOffers, highlight),
      ],
    ),
  ]);
}

pw.Widget _emiSection(QuoteData d) => pw.Column(children: [
      pw.Center(
          child: pw.Text('EMI Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Table(border: pw.TableBorder.all(), children: [
        _row('Finance On: ${d.financeOn}', 'Loan Amount: ${d.loanAmount}'),
        _row('ROI: ${d.roi}%', 'Tenure in Years: ${d.tenureYears}'),
        _row('EMI Amount: ${d.emiAmount}',
            '* ROI Will Subject to change as per CIBIL score.'),
      ])
    ]);

pw.Widget _termsSection() => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Terms and Conditions:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        _term('1. All Products are as per company standards.'),
        _term('2. Delivery subject to availability.'),
        _term('3. Price applicable at invoicing date.'),
        _term('4. Delivery only after full payment.'),
        _term('5. Jurisdiction applicable.'),
      ],
    );

pw.Widget _bankSection(QuoteData d) => pw.Column(children: [
      _bankRow('Bank Name', d.bankName),
      _bankRow('Beneficiary', d.beneficiary),
      _bankRow('Account Number', d.accountNumber),
      _bankRow('IFSC Code', d.ifscCode),
      _bankRow('Branch Name', d.branchName),
    ]);

pw.TableRow _row(String left, String right) => pw.TableRow(children: [
      pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(left, style: const pw.TextStyle(fontSize: 8))),
      pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(right, style: const pw.TextStyle(fontSize: 8))),
    ]);

pw.TableRow _priceRow(String label, double value) => pw.TableRow(children: [
      pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 8))),
      pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(value.toStringAsFixed(0),
                  style: const pw.TextStyle(fontSize: 8)))),
    ]);

pw.TableRow _highlightPriceRow(String label, double value, PdfColor color) =>
    pw.TableRow(
      decoration: pw.BoxDecoration(color: color),
      children: [
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Rs. ${value.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
      ],
    );

pw.Widget _term(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 7)),
    );

pw.Widget _bankRow(String label, String value) => pw.Row(children: [
      pw.SizedBox(
          width: 90,
          child: pw.Text(label,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
      pw.Text(': '),
      pw.Expanded(
          child: pw.Text(value,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue))),
    ]);

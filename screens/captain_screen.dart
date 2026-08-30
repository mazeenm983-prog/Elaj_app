import 'package:flutter/material.dart';

class CaptainScreen extends StatefulWidget {
  const CaptainScreen({super.key});

  @override
  State<CaptainScreen> createState() => _CaptainScreenState();
}

class _CaptainScreenState extends State<CaptainScreen> {
  // قائمة تجريبية بالطلبات المتاحة للكابتن
  final List<Map<String, String>> _availableOrders = [
    {
      'id': '101',
      'medicine': 'بنادول إكسترا (علبتين) + فيتامين سي',
      'address': 'الخرطوم - الرياض - شارع المشتل',
      'status': 'في الانتظار'
    },
    {
      'id': '102',
      'medicine': 'أنسولين لانتوس + شريط قياس السكر',
      'address': 'أم درمان - الشهداء',
      'status': 'في الانتظار'
    },
  ];

  void _acceptOrder(int index) {
    setState(() {
      _availableOrders[index]['status'] = 'تم القبول (جاري التوصيل)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم قبول الطلب رقم #${_availableOrders[index]['id']} بنجاح!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الكابتن - الطلبات المتاحة'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _availableOrders.length,
        itemBuilder: (context, index) {
          final order = _availableOrders[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('طلب رقم: #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('الدواء المطلوب: ${order['medicine']}'),
                  const SizedBox(height: 4),
                  Text('العنوان: ${order['address']}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(order['status']!),
                        backgroundColor: order['status']!.contains('قبول') ? Colors.green.shade100 : Colors.orange.shade100,
                      ),
                      if (!order['status']!.contains('قبول'))
                        ElevatedButton(
                          onPressed: () => _acceptOrder(index),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue, foregroundColor: Colors.white),
                          child: const Text('قبول الطلب'),
                        ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

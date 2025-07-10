import 'package:flutter/material.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      "title": "Intelligent Weed Elimination",
      "image": "assets/weed.jpg",
      "price": 11.00,
      "description":
          "Leverage precision agriculture with our intelligent weed elimination service. This solution harnesses cutting-edge recognition systems to identify and remove invasive weeds with minimal impact on your crops. Using environmentally conscious methods, we help protect your yield and promote long-term soil health.",
      "features": [
        "Smart weed detection algorithms",
        "Sustainable, non-invasive removal",
        "Live field diagnostics",
        "High-resolution weed distribution maps",
      ],
    },
    {
      "title": "Comprehensive Soil Diagnostics & Nutrient Profiling",
      "image": "assets/neutrient.jpg",
      "price": 11.00,
      "description":
          "Understand your soil like never before with our in-depth analysis and nutrient profiling. We provide accurate assessments of your land’s fertility and tailored suggestions to maximize agricultural productivity, ensuring balanced crop nourishment throughout the season.",
      "features": [
        "Granular soil composition breakdown",
        "Real-time nutrient mapping reports",
        "Data-driven fertilizer application guidance",
        "Year-over-year comparison and forecasting",
      ],
    },

    {
      "title": "Targeted Disease Detection & Treatment",
      "image": "assets/disease.jpeg",
      "price": 11.00,
      "description":
          "Combat plant diseases effectively with our advanced detection and treatment service. Utilizing high-resolution imaging, machine learning, and drone-based delivery, we provide rapid identification and precision medication—reducing spread and maximizing crop health.",
      "features": [
        "AI-based disease classification",
        "Precision spraying via autonomous drones",
        "Real-time disease severity scoring",
        "Customized treatment plans per crop type",
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Our Services"),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Agricultural Services",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Explore next-generation solutions tailored to modern farming",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  children:
                      services
                          .map(
                            (service) => Card(
                              margin: EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ServiceDetailsScreen(
                                            service: service,
                                          ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.asset(
                                              service["image"],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  service["title"],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[900],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "\$${service["price"]}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        service["description"],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            (service["features"]
                                                    as List<String>)
                                                .map(
                                                  (feature) => Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      feature,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

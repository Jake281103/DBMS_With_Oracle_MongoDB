// MongoDB implementation for resetting the schema
db.users.drop();
db.menuitems.drop();
db.restaurants.drop();
db.orders.drop();
db.payments.drop();

// Users collection

db.createCollection("users");
db.users.insertMany([
{
  "_id": ObjectId(),
  "userid": 100,
  "firstname": "John",
  "lastname": "Smith",
  "email": "john@outlet.com",
  "dateofbirth": "1999-05-20",
  "address": "123 Maple Street, Springfield, IL 62701, USA",
  "phone": "094876657575",
  "type": "customer",
  "customerid": "CU001",
  "registerdate": new Date(),
  "status": "Active"
},
{
  "_id": ObjectId(),
  "userid": 101,
  "firstname": "Robert",
  "lastname": "Brown",
  "email": "robert.brown@example.net",
  "dateofbirth": "1992-03-07",
  "address": "789 Pine Avenue, Chicago, IL 60601, USA",
  "phone": "093476554321",
  "type": "customer",
  "customerid": "CU002",
  "registerdate": new Date(),
  "status": "Active"
},
{
  "_id": ObjectId(),
  "userid": 102,
  "firstname": "Michael",
  "lastname": "Taylor",
  "email": "michael.taylor@domain.org",
  "dateofbirth": "1978-12-05",
  "address": "987 Birch Road, Miami, FL 33101, USA",
  "phone": "098456765432",
  "type": "customer",
  "customerid": "CU003",
  "registerdate": new Date(),
  "status": "Inactive"
},
{
  "_id": ObjectId(),
  "userid": 103,
  "firstname": "Walker",
  "lastname": "Don",
  "email": "walkerdon@gmail.com",
  "dateofbirth": "1999-05-25",
  "address": "126 Maple Street, Springfield, IL 62701, USA",
  "phone": "094878957575",
  "type": "customer",
  "customerid": "CU004",
  "registerdate": new Date(),
  "status": "Active"
},
{
  "_id": ObjectId(),
  "userid": 104,
  "firstname": "Sophia",
  "lastname": "Brown",
  "email": "sophiabrown@yahoo.com",
  "dateofbirth": "1998-11-20",
  "address": "45 Pine Street, Chicago, IL 60601, USA",
  "phone": "094567890123",
  "type": "deliveryman",
  "deliverymanid": "DM001",
  "vehicle": "Mountain Bike, Red Color",
  "status": "Unavailable"
},
{
  "_id": ObjectId(),
  "userid": 105,
  "firstname": "Ava",
  "lastname": "Williams",
  "email": "avawilliams@outlook.com",
  "dateofbirth": "1990-07-30",
  "address": "67 Cedar Lane, Miami, FL 33101, USA",
  "phone": "098765432123",
  "type": "deliveryman",
  "deliverymanid": "DM002",
  "vehicle": "E-Bike, Green Color",
  "status": "Unavailable"
},
{
  "_id": ObjectId(),
  "userid": 106,
  "firstname": "Willan",
  "lastname": "Mike",
  "email": "willanmike@gmail.com",
  "dateofbirth": "1999-05-25",
  "address": "126 Maple Street, Springfield, IL 62701, USA",
  "phone": "094878957575",
  "type": "deliveryman",
  "deliverymanid": "DM003",
  "vehicle": "Mountain Bike, Yellow Color",
  "status": "Available"
},
{
  "_id": ObjectId(),
  "userid": 107,
  "firstname": "James",
  "lastname": "Clark",
  "email": "james.clark@example.com",
  "dateofbirth": "1988-03-15",
  "address": "789 Pine Avenue, San Francisco, CA 94101, USA",
  "phone": "094876543210",
  "type": "deliveryman",
  "deliverymanid": "DM004",
  "vehicle": "Normal Bike, Gray Color",
  "status": "Available"
}
]);


// Menuitems Collection

db.createCollection("menuitems");
db.menuitems.insertMany([
{
  "_id": ObjectId(),
  "itemid": 1,
  "name": "Burger",
  "description": "Delicious beef burger",
  "price": 5.99,
  "category": "Fast Food"
},{
  "_id": ObjectId(),
  "itemid": 2,
  "name": "Pizza",
  "description": "Cheesy margherita pizza",
  "price": 8.99,
  "category": "Fast Food"
},
{
  "_id": ObjectId(),
  "itemid": 3,
  "name": "Coke",
  "description": "Refreshing cola drink",
  "price": 1.99,
  "category": "Drinks"
},
{
  "_id": ObjectId(),
  "itemid": 4,
  "name": "Espresso",
  "description": "2 shots of espresso",
  "price": 4.33,
  "category": "Drinks"
},
{
  "_id": ObjectId(),
  "itemid": 5,
  "name": "Cafe Latte",
  "description": "shot of espresso + 8-10 oz. of steamed milk + 1 cm of foam",
  "price": 5.99,
  "category": "Drinks"
},
{
  "_id": ObjectId(),
  "itemid": 6,
  "name": "Iced Coffee",
  "description": "drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + flavoring syrup to taste",
  "price": 6.55,
  "category": "Drinks"
},
{
  "_id": ObjectId(),
  "itemid": 7,
  "name": "Pizza Two",
  "description": "Seedfood margherita pizza",
  "price": 8.99,
  "category": "Fast Food"
}
]);


// Restaurants Collection

db.createCollection("restaurants");
db.restaurants.insertMany([
  {
    "_id": ObjectId(),
    "restaurantid": 1,
    "name": "Pizza Place",
    "address": "789 Pine Road",
    "phone": "555-1234",
    "menu": [
      {"itemid": 2,"name": "Pizza","description": "Cheesy margherita pizza","price": 8.99,"category": "Fast Food"},
      {"itemid": 7,"name": "Pizza Two","description": "Seedfood margherita pizza","price": 8.99,"category": "Fast Food"}
    ]
  },
  {
    "_id": ObjectId(),
    "restaurantid": 2,
    "name": "Burger Joint",
    "address": "123 Main Street",
    "phone": "555-5678",
    "menu": [
      {"itemid": 1,"name": "Burger","description": "Delicious beef burger","price": 5.99,"category": "Fast Food"}
    ]
  },
  {
    "_id": ObjectId(),
    "restaurantid": 3,
    "name": "Coffee Bean",
    "address": "223 Main Road",
    "phone": "555-6345",
    "menu": [
      {"itemid": 3,"name": "Coke","description": "Refreshing cola drink","price": 1.99,"category": "Drinks"},
      {"itemid": 4,"name": "Espresso","description": "2 shots of espresso","price": 4.33,"category": "Drinks"},
      {"itemid": 5,"name": "Cafe Latte","description": "shot of espresso + 8-10 oz. of steamed milk + 1 cm of foam","price": 5.99,"category": "Drinks"},
      {"itemid": 6,"name": "Iced Coffee","description": "drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + flavoring syrup to taste","price": 6.55,"category": "Drinks"}
    ]
  },
  {
    "_id": ObjectId(),
    "restaurantid": 4,
    "name": "Coffee Diary",
    "address": "223 Main Road",
    "phone": "555-6345",
    "menu": [
      {"itemid": 4,"name": "Espresso","description": "2 shots of espresso","price": 4.33,"category": "Drinks"},
      {"itemid": 5,"name": "Cafe Latte","description": "shot of espresso + 8-10 oz. of steamed milk + 1 cm of foam","price": 5.99,"category": "Drinks"},
      {"itemid": 6,"name": "Iced Coffee","description": "drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + flavoring syrup to taste","price": 6.55,"category": "Drinks"},
      {"itemid": 1,"name": "Burger","description": "Delicious beef burger","price": 5.99,"category": "Fast Food"}
    ]
  }
]);


// Orders Collection

db.createCollection("orders");
db.orders.insertMany([
{
  "_id": ObjectId(),
  "orderid": 1,
  "orderdate": new Date(),
  "orderstatus": "Completed",
  "totalamount": 12.54,
  "consumer": "CU001",
  "delivery": "DM001",
  "restaurant": 4,
  "items": [
	     {"itemid": 1,"name": "Burger","description": "Delicious beef burger","price": 5.99,"category": "Fast Food"},
	     {"itemid": 6,"name": "Iced Coffee","description": "drip coffee or espresso + 4 oz. of ice + 4-6 oz of milk or water + flavoring syrup to taste",
	     "price": 6.55,"category": "Drinks"}
  	  ]
},
{
  "_id": ObjectId(),
  "orderid": 2,
  "orderdate": new Date(),
  "orderstatus": "Assigned to Delivery Person: DM002",
  "totalamount": 6.32,
  "consumer": "CU002",
  "delivery": "DM002",
  "restaurant": 3,
  "items": [
  	     {"itemid": 3,"name": "Coke","description": "Refreshing cola drink","price": 1.99,"category": "Drinks"},
	     {"itemid": 4,"name": "Espresso","description": "2 shots of espresso","price": 4.33,"category": "Drinks"}
	   ]
}
]);



// Payments Collection
db.createCollection("payments");
db.payments.insertMany([
{
  "_id": ObjectId(),
  "paymentid":1,
  "paymentdate": new Date(),
  "amount": 13.79,
  "order_id": 1
},
{
  "_id": ObjectId(),
  "paymentid":2,
  "paymentdate": new Date(),
  "amount": 6.95,
  "order_id": 2
}
]);


// Query 1
db.orders.aggregate([
  {
    $lookup: {
      from: "payments",
      localField: "orderid",
      foreignField: "order_id",
      as: "payment_details"
    }
  },
  {
    $unwind: "$payment_details"
  },
  {
    $lookup: {
      from: "users",
      localField: "consumer",
      foreignField: "customerid",
      as: "consumer_details"
    }
  },
  {
    $unwind: "$consumer_details"
  },
  {
    $lookup: {
      from: "restaurants",
      localField: "restaurant",
      foreignField: "restaurantid",
      as: "restaurant_details"
    }
  },
  {
    $unwind: "$restaurant_details"
  },
  {
    $match: {
      orderstatus: "Completed"
    }
  },
  {
    $addFields: {
      customer_name: {
        $concat: [
          "$consumer_details.firstname",
          " ",
          "$consumer_details.lastname"
        ]
      },
      restaurant_name: "$restaurant_details.name",
      paymentid: "$payment_details.paymentid", 
      paymentdate: "$payment_details.paymentdate", 
      payment_amount: "$payment_details.amount"
    }
  },
  {
    $project: {
      _id: 0,
      orderid: 1,
      orderdate: 1,
      totalamount: 1,
      orderstatus: 1,
      customer_name: 1,
      restaurant_name: 1,
      paymentid: 1,
      paymentdate: 1,
      payment_amount: 1
    }
  }
]);


// Query 2
db.menuitems.aggregate([
  {
    $lookup: {
      from: "restaurants",
      let: { itemid: "$itemid" },
      pipeline: [
        {
          $unwind: "$menu"
        },
        {
          $match: {
            $expr: { $eq: ["$menu.itemid", "$$itemid"] } 
          }
        },
        {
          $project: {
            _id: 0, 
            itemid: 1, 
            name: 1 
          }
        }
      ],
      as: "restaurant_match" 
    }
  },
  {
    $match: {
      restaurant_match: { $ne: [] }
    }
  },
 {
    $project: {
      _id: 0, 
      itemid: 1, 
      name: 1, 
    }
  }
]);


// Query 3
db.restaurants.aggregate([
  {
    $unwind: "$menu"
  },
  {
    $lookup: {
      from: "menuitems",        
      localField: "menu.itemid", 
      foreignField: "itemid",    
      as: "menu_item"            
    }
  },
  {
    $unwind: "$menu_item"
  },
  {
    $match: {
      "menu_item.price": { $gt: 5.00 }
    }
  },
  {
    $match: {
      "menu_item.category": { $in: ["Fast Food", "Drinks"] }
    }
  },
  {
    $group: {
      _id: {
        name: "$name",              
        address: "$address",        
        phone: "$phone",            
        restaurantid: "$restaurantid" 
      },
      MenuItems: {
        $push: "$menu_item.name"   
      },
      MenuItemCount: {
        $sum: 1                     
      },
      Categories: {
        $addToSet: "$menu_item.category" 
      }
    }
  },
  {
    $project: {
      _id: 0,                                   
      RestaurantName: "$_id.name",             
      MenuItems: {                              
        $reduce: {
          input: "$MenuItems",
          initialValue: "",
          in: {
            $cond: [
              { $eq: ["$$value", ""] },
              "$$this",
              { $concat: ["$$value", ", ", "$$this"] }
            ]
          }
        }
      },
      MenuItemCount: 1,                        
      RestaurantAddress: "$_id.address",        
      ContactNumber: "$_id.phone",              
      Categories: {                            
        $reduce: {
          input: "$Categories",
          initialValue: "",
          in: {
            $cond: [
              { $eq: ["$$value", ""] },
              "$$this",
              { $concat: ["$$value", ", ", "$$this"] }
            ]
          }
        }
      }
    }
  },
  {
    $sort: {
      MenuItemCount: -1
    }
  }
]);



// Query 4
db.orders.aggregate([
  {
    $addFields: {
      expected_delivery_time: {
        $add: ["$orderdate", 3600000] 
      }
    }
  },
  {
    $addFields: {
      delivery_status: {
        $cond: {
          if: { $gte: [new Date(), "$expected_delivery_time"] },
          then: "Delivered",
          else: "In Progress"
        }
      }
    }
  },
  {
    $addFields: {
      time_elapsed_ms: {
        $subtract: [new Date(), "$orderdate"] 
      }
    }
  },
  {
    $addFields: {
      time_elapsed: {
        $concat: [
          { $toString: { $floor: { $divide: ["$time_elapsed_ms", 3600000] } } }, 
          ":",
          { $toString: { $mod: [{ $floor: { $divide: ["$time_elapsed_ms", 60000] } }, 60] } }, 
          ":",
          { $toString: { $mod: [{ $floor: { $divide: ["$time_elapsed_ms", 1000] } }, 60] } }, 
          ".",
          { $toString: { $mod: ["$time_elapsed_ms", 1000] } } 
        ]
      }
    }
  },
  {
    $project: {
      _id: 0,                       
      orderid: 1,                    
      orderdate: 1,                 
      expected_delivery_time: 1,     
      delivery_status: 1,            
      time_elapsed: 1             
    }
  }
]);



// Query 5
db.restaurants.aggregate([
  {
    $lookup: {
      from: "orders",
      localField: "restaurantid", 
      foreignField: "restaurant", 
      as: "orders" 
    }
  },
  {
    $unwind: {
      path: "$orders",
      preserveNullAndEmptyArrays: true 
    }
  },
  {
    $group: {
      _id: "$name", // Group by restaurant name
      total_sales: { $sum: { $ifNull: ["$orders.totalamount", 0 ] } }, 
      average_sales: { $avg: "$orders.totalamount" } 
    }
  },
  {
    $facet: {
      byRestaurant: [
        {
          $addFields: {
            restaurant_name: "$_id", 
          }
        }
      ],
      grandTotalSales: [
        {
          $group: {
            _id: null,
            grand_total: { $sum: "$total_sales" } 
          }
        }
      ]
    }
  },
  {
    $project: {
      byRestaurant: 1, // Keep byRestaurant data
      grandTotalSales: { $arrayElemAt: ["$grandTotalSales.grand_total", 0] } 
    }
  },
  {
    $unwind: "$byRestaurant" 
  },
  {
    $addFields: {
      "byRestaurant.sales_contribution": {
        $cond: [
          { $gt: ["$grandTotalSales", 0] },
          {
            $round: [
              {
                $multiply: [
                  { $divide: ["$byRestaurant.total_sales", "$grandTotalSales"] },
                  100
                ]
              },
              2
            ]
          },
          null
        ]
      }
    }
  },
  {
    $match: {
      "byRestaurant.restaurant_name": { $ne: null }
    }
  },
  {
    $replaceRoot: { newRoot: "$byRestaurant" }
  },
  {
    $sort: { total_sales: -1 }
  }
]);


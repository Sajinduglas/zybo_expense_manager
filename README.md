# zybo_expense_manager

A new Flutter project.

# **Flutter Technical Challenge: Proactive Expense Manager**

**Time Limit: 2 Days**

## **Project Overview**

Build a hybrid **Local/Cloud** Expense Manager application. This challenge evaluates your proficiency in relational persistence, reactive state management with BLoC, and robust data synchronization between a local SQLite database and a production API.

## **1\. Technical Stack (Mandatory)**

| Category | Requirement |
| :---- | :---- |
| **State Management** | flutter\_bloc \+ equatable |
| **Local Database** | sqflite (Relational schema required) |
| **Identity** | uuid package (IDs must be generated locally at creation) |
| **Notifications** | flutter\_local\_notifications |
| **Authentication** | Phone Number \+ OTP Logic |

## **2\. Functional Requirements**

### **Phase 1: Authentication & Onboarding**

1. **Onboarding:** A 3-screen walkthrough using static images and high-quality typography.  
2. **Authentication Flow:**  
   * **Step 1:** User enters phone. API returns user\_exists (bool) and otp.  
   * **Step 2:** User enters OTP (displayed on-screen for testing).  
   * **Step 3 (Routing):**  
     * If user\_exists \== true: API returns nickname and token. Proceed to Home.  
     * If user\_exists \== false: User must enter a nickname. Call create-account to get the token.  
3. **Local Setup:** Save the nickname and token to shared\_preferences.

### **Phase 2: Relational Schema & Identity**

* **UUIDs:** Generate a UUID locally for every new Transaction or Category.  
* **Schema Definition:**  
  * **Categories Table:** id (UUID), name (String), is\_synced (0 or 1), is\_deleted (0 or 1).  
  * **Transactions Table:** id (UUID), amount (Double), note (String), type (String: 'credit' or 'debit'), category\_id (String/FK), is\_synced (0 or 1), and is\_deleted (0 or 1).  
* **SQL Challenge:** Use a **SQL JOIN** in your repository to fetch the Category Name for each Transaction card display.

### **Phase 3: Dashboard & UX**

* **Home:** Display live "Total Expense", “Total Income”, and the 10 most recent transactions where is\_deleted \= 0\.  
* **Transactions page:**  List all the transactions.  
* **Category Management:** A section view to create and remove expense categories.  
* **UX:** Use **Shimmer loaders** for initial loads and **Active Animations** during sync operations. Use the assets provided in the Figma design.

### **Phase 4: Notifications & Limit Tracking**

* **Budget Limit Alerts:** \* Implement local logic to track if total **debit** (expenses) for the current month exceeds a threshold (e.g., ₹1000).  
  Trigger an **instant local notification** the moment a new debit transaction is added that pushes the total over the limit.

UI Design: [https://www.figma.com/design/PvKsf3DiyHlvVto41QGBHp/Skill-Test-Expense-Tracker?node-id=0-1\&p=f](https://www.figma.com/design/PvKsf3DiyHlvVto41QGBHp/Skill-Test-Expense-Tracker?node-id=0-1&p=f)

Prototype: [https://www.figma.com/proto/PvKsf3DiyHlvVto41QGBHp/Skill-Test-Expense-Tracker?node-id=1-2\&viewport=95%2C225%2C0.18\&t=tbNLHqacWSzbRKa5-1\&scaling=scale-down\&content-scaling=fixed\&starting-point-node-id=1%3A2\&page-id=0%3A1](https://www.figma.com/proto/PvKsf3DiyHlvVto41QGBHp/Skill-Test-Expense-Tracker?node-id=1-2&viewport=95%2C225%2C0.18&t=tbNLHqacWSzbRKa5-1&scaling=scale-down&content-scaling=fixed&starting-point-node-id=1%3A2&page-id=0%3A1)

## **3\. The Synchronisation & Deletion Logic**

### **3.1 Local Actions (Instant UI)**

* **Add:** Insert into SQL with is\_synced \= 0\. Update BLoC state immediately.  
* **Delete:** Update SQL to is\_deleted \= 1\. **Immediately filter this out** of the BLoC state so the user sees it vanish instantly.

### **3.2 The Sync Workflow (Triggered by "Sync" Button)**

**Step A: Clean up Deletions (Cloud Purge)**

1. Find all local records (Transactions first, then Categories) where is\_deleted \= 1\.  
2. Send those IDs to the respective delete endpoints.  
3. Only after the API confirms success, permanently delete (DELETE FROM...) those records from the local SQLite database.

**Step B: Upload New Data (Cloud Backup)**

1. **Sync Categories First:** Batch upload local categories where is\_synced \= 0 AND is\_deleted \= 0\.  
2. **Sync Transactions Second:** Once categories are synced, batch upload transactions where is\_synced \= 0 AND is\_deleted \= 0\.  
3. Update local records in SQL to is\_synced \= 1 only after API confirmation.

## **4\. API Data Contracts**

**Base URL:** https://appskilltest.zybotech.in

### **4.1 Authentication Endpoints**

#### **\[POST\] /auth/send-otp/**

* **Request Body:** { "phone": "+919876543210" }  
* **Response (Existing User):**  
  {  
    "status": "success",  
    "otp": "123456",  
    "user\_exists": true,  
    "nickname": "JohnDoe",  
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  
  }  
* **Response (Existing User):**  
  {  
   "status": "success",  
    "otp": "123456",  
    "user\_exists": false,  
    "nickname": null,   
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  
  }

#### **\[POST\] /auth/create-account/**

* **Request Body:** 

{   
	"phone": "+919876543210",   
	"nickname": "JohnDoe" 

}

* **Response:** 

{ "status": "success",   
	"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." }

### **4.2 Category Endpoints**

#### **\[GET\] /categories/**

* **Response:**  
  {  
    "status": "success",  
    "categories": \[  
      { "id": "550e8400-e29b-41d4-a716-446655440000",   
  	"name": "Food" }  
    \]  
  }

#### **\[POST\] /categories/add/** 

* **Request Body:**

     { "category\_id": "550e8400-e29b-41d4-a716-446655440000",  
	 "name": "Food" }

* **Response:**  
  {   
    "status": "success",   
    "synced\_ids": \["550e8400-e29b-41d4-a716-446655440000"\]  
  }

#### **\[DELETE\] /categories/delete/ (Batch Delete)**

* **Request Body:** { "ids": \["550e8400-e29b-41d4-a716-446655440000"\] }  
* **Response:** { "status": "success",   
  "deleted\_ids": \["550e8400-e29b-41d4-a716-446655440000"\] }

### **4.3 Transaction Endpoints**

#### **\[GET\] /transactions/**

* **Response:**  
  {  
    "status": "success",  
    "transactions": \[  
      {  
        "id": "f7d50524-660f-4a6a-a232-63f106e9f01c",  
        "amount": 50.0,  
        "note": "travel"  
  	"type": "credit",  
        "category": "test2 category",  
        "timestamp": "2023-10-27T10:00:00Z"  
      }  
    \]  
  }

#### **\[POST\] /transactions/add/ (Batch Sync)**

* **Request Body:**  
  {  
    "transactions": \[  
      {  
        "id": "9cd6f10e-376d-4344-b5fb-60d5bb152f69",  
        "amount": 50,  
        "note": "Travel",  
  	"type": "credit",  
        "category\_id": "550e8400-e29b-41d4-a716-446655440000",  
        "timestamp": "2023-10-27 10:00:00"  
      }  
    \]  
  }

* **Response:**  
  {  
    "status": "success",  
    "synced\_ids": \["9cd6f10e-376d-4344-b5fb-60d5bb152f69"\]  
  }

#### **\[DELETE\] /transactions/delete/ (Batch Delete)**

* **Request Body:** { "ids": \["d7187213-798f-4ce2-92b3-b1adf586b41c"\] }  
* **Response:**  
  {  
    "status": "success",  
    "deleted\_ids": \["d7187213-798f-4ce2-92b3-b1adf586b41c"\]  
  }

Postman collection: [https://drive.google.com/file/d/1VMC4UgahflnV0Wk1oN36cQp-RN8b4zp\_/view?usp=sharing](https://drive.google.com/file/d/1VMC4UgahflnV0Wk1oN36cQp-RN8b4zp_/view?usp=sharing)

## **5\. Evaluation Criteria**

### **5.1 UI Fidelity & UX Implementation**

* **Design Accuracy:** Translation of Figma designs and typography requirements.  
* **Loading States:** Implementation of shimmers and active sync animations.  
* **Form Handling:** Proper validation and focus management.

### **5.2 BLoC Architecture & State Management**

* **Reactive Consistency:** Instant UI updates for Add/Delete operations.  
* **Immutable State:** Proper use of Bloc and Equatable.  
* **Dependency Injection:** Proper provision and disposal of BLoCs.

### **5.3 Core Logic & Sync Integrity**

* **Soft Delete Logic:** Hiding items reactively while maintaining sync state.  
* **Relational Sync:** Ensuring Categories are synced before Transactions that depend on them.  
* **Batch Efficiency:** Correct calculation and display of Credit vs Debit balances.

### **5.4 Backend & Platform Integration**

* **SQL Mastery:** Relational schema integrity and SQL JOIN proficiency.  
* **Identity Management:** Flawless UUID usage across all layers.  
* **OS Services:** Functional local notifications and reminders.

**Deliverables:**  

* Project as Github repo (Make sure to make it public)  
* .apk build


Support Contact: 

Abhijith M: **7907604480**
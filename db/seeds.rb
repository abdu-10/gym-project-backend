# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# db/seeds.rb

puts "Cleaning database..."
Testimonial.destroy_all

puts "Creating testimonials..."

testimonials_data = [
  {
    quote: "Joining FitLife has completely transformed my fitness journey. The trainers are exceptional, and the community is so supportive!",
    author: "Sarah Johnson",
    role: "Member for 2 years",
    image: "https://plus.unsplash.com/premium_photo-1691784781482-9af9bce05096?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8cGFzc3BvcnQlMjBwaG90b3N8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600",
    rating: 5
  },
  {
    quote: "The variety of classes and state-of-the-art equipment keep me motivated. I've never felt stronger or more confident!",
    author: "Mike Chen",
    role: "Member for 1 year",
    image: "https://images.unsplash.com/photo-1666852327656-5e9fd213209b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687",
    rating: 5
  },
  {
    quote: "FitLife's personalized training programs helped me achieve my fitness goals faster than I ever imagined possible.",
    author: "Emma Rodriguez",
    role: "Member for 3 years",
    image: "https://plus.unsplash.com/premium_photo-1668485968660-67a0f563d59a?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687",
    rating: 5
  },
  {
    quote: "The nutrition counseling and fitness classes at FitLife have helped me develop a healthy lifestyle that I can maintain for life.",
    author: "David Thompson",
    role: "Member for 6 months",
    image: "https://plus.unsplash.com/premium_photo-1693258698597-1b2b1bf943cc?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDR8fHxlbnwwfHx8fHw%3D&auto=format&fit=crop&q=60&w=600",
    rating: 5
  },
  {
    quote: "The flexible scheduling and variety of classes at FitLife make it easy to stay consistent with my workouts.",
    author: "Jessica Lee",
    role: "Member for 8 months",
    image: "https://plus.unsplash.com/premium_photo-1682096446235-897adc1a189b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDExfHx8ZW58MHx8fHx8&auto=format&fit=crop&q=60&w=600",
    rating: 4
  }
]

# This creates the records.
# Using create! will raise an error if a validation fails (which is good for seeds!)
testimonials_data.each do |data|
  Testimonial.create!(data)
end

puts "Finished!"
puts "Created #{Testimonial.count} testimonials."

# plans


puts "Cleaning join tables..."
Membership.destroy_all
User.destroy_all # Let's also clean up the Postman test user


puts "Cleaning Plans table..."
Plan.destroy_all

puts "Creating membership plans..."

plans_data = [
  {
    name: 'Basic',
    price: '$49',           # Display Price
    price_in_cents: 4900,   # Stripe Price ($49.00)
    period: '1 Month',
    popular: false,
    features: [
      '24/7 Gym Access',
      'Access to Heated Pool & Spa',
      'Access to Padel Courts',
      '1 Free PT Session',
      'Free Fitness Assessment',
      'Locker Room & Showers'
    ]
  },
  {
    name: 'Premium',
    price: '$249',          # Saves them $45 compared to monthly
    price_in_cents: 24900,  # Stripe Price ($249.00)
    period: '6 Months',
    popular: true,          # This is the one we want to sell most!
    features: [
      '24/7 VIP Gym Access',
      'Heated Pool, Spa & Sauna',
      'Priority Padel Booking',
      '3 Free PT Sessions',
      '2 Free Body Composition Scans',
      'Personalized Nutrition Plan',
      'Guest Pass (2/month)'
    ]
  },
  {
    name: 'Elite',
    price: '$499',          # Saves them $89 compared to monthly
    price_in_cents: 49900,  # Stripe Price ($499.00)
    period: '1 Year',
    popular: false,
    features: [
      'All Access (Gym, Pool, Spa, Padel)',
      '6 Free PT Sessions',
      'Monthly Body Composition Analysis',
      'Full Personalized Nutrition Plan',
      'Unlimited Guest Passes',
      'Private Locker',
      'Free Smoothies (1/visit)'
    ]
  }
]

# db/seeds.rb

ClassBooking.destroy_all

classes_data = [
  {
    name: "HIIT Challenge",
    category: "Cardio",
    # Notice the change from 'image' to 'image_url'
    image_url: "https://images.unsplash.com/photo-1536922246289-88c42f957773?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8SElJVHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=600",
    duration: "45 mins",
    instructor: "Alex Johnson",
    time: "Mon & Wed, Fri 6:00 AM",
    capacity: 20
  },
  {
    name: "Powerlifting",
    category: "Strength",
    image_url: "https://images.unsplash.com/photo-1534368270820-9de3d8053204?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG93ZXJsaWZ0aW5nfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600",
    duration: "60 mins",
    instructor: "Sarah Lee",
    time: "Tue & Thu 5:30 PM",
    capacity: 15
  },
  {
    name: "CrossFit",
    category: "Strength",
    image_url: "https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y3Jvc3NmaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600",
    duration: "60 mins",
    instructor: "Mike Brown",
    time: "Mon & Wed 7:00 PM",
    capacity: 25
  },
  {
    name: "Pilates",
    category: "Flexibility",
    image_url: "https://images.unsplash.com/photo-1717500251833-d807c5753ded?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTR8fHBpbGF0ZXN8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600",
    duration: "50 mins",
    instructor: "Emily Davis",
    time: "Sat 9:00 AM",
    capacity: 10
  },
  {
    name: "Zumba",
    category: "Cardio",
    image_url: "https://images.unsplash.com/photo-1518310383802-640c2de311b2?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8enVtYmF8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600",
    duration: "55 mins",
    instructor: "Sophia Wilson",
    time: "Sun 10:00 AM",
    capacity: 30
  },
  {
    name: "Yoga Flow",
    category: "Mind & Body",
    image_url: "https://plus.unsplash.com/premium_photo-1661371363253-e99d4212ae7f?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fHlvZ2ElMjBjbGFzc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=600",
    duration: "60 mins",
    instructor: "Olivia Martinez",
    time: "Daily 8:00 AM",
    capacity: 20
  },
  {
    name: "Meditation & Mindfulness",
    category: "Mind & Body",
    image_url: "https://plus.unsplash.com/premium_photo-1710467003556-0c3576801d86?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8bWVkaXRhdGlvbiUyMGNsYXNzfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600",
    duration: "30 mins",
    instructor: "James Smith",
    time: "Daily 7:00 AM",
    capacity: 15
  },
  {
    name: "Boxing Basics",
    category: "Strength",
    image_url: "https://plus.unsplash.com/premium_photo-1663134170454-ebca105ee9ab?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Ym94aW5nJTIwY2xhc3N8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600",
    duration: "45 mins",
    instructor: "Alex Johnson",
    time: "Mon & Wed, Fri 6:00 AM",
    capacity: 20
  }
]

ClassBooking.create!(classes_data)

puts "Created #{ClassBooking.count} ClassBookings"

plans_data.each do |plan_data|
  Plan.create!(plan_data)
end

puts "Created #{Plan.count} plans."

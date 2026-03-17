import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
               
                Color(red: 0.039, green: 0.039, blue: 0.039)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
               
                    HStack {
                        Spacer()
                        SoundButton(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))
                                .tracking(-0.3125)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 24)
                    }
                    .frame(height: 48)
                    
              
                    Spacer()
                    
                  
                    TabView(selection: $currentPage) {
                      
                        OnboardingPage1(screenWidth: geometry.size.width)
                            .tag(0)
                        
                     
                        OnboardingPage2(screenWidth: geometry.size.width)
                            .tag(1)
                        
                      
                        OnboardingPage3(screenWidth: geometry.size.width)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    Spacer()
                    
                   
                    VStack(spacing: 32) {
                       
                        HStack(spacing: 8) {
                            if currentPage == 0 {
                               
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color(red: 1.0, green: 0.176, blue: 0.176))
                                    .frame(width: 32, height: 8)
                                    .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.5), radius: 12, x: 0, y: 0)
                            } else {
                                Circle()
                                    .fill(Color(red: 0.165, green: 0.165, blue: 0.165))
                                    .frame(width: 8, height: 8)
                            }
                            
                            if currentPage == 1 {
                          
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color(red: 1.0, green: 0.176, blue: 0.176))
                                    .frame(width: 32, height: 8)
                                    .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.5), radius: 12, x: 0, y: 0)
                            } else {
                                Circle()
                                    .fill(Color(red: 0.165, green: 0.165, blue: 0.165))
                                    .frame(width: 8, height: 8)
                            }
                            
                            if currentPage == 2 {
                       
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color(red: 1.0, green: 0.176, blue: 0.176))
                                    .frame(width: 32, height: 8)
                                    .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.5), radius: 12, x: 0, y: 0)
                            } else {
                                Circle()
                                    .fill(Color(red: 0.165, green: 0.165, blue: 0.165))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                       
                        SoundButton(action: {
                            if currentPage < 2 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                hasCompletedOnboarding = true
                            }
                        }) {
                        HStack(spacing: 8) {
                            if currentPage == 2 {
                      
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Start Tracking")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .tracking(-0.439)
                            } else {
                                Text("Next")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .tracking(-0.439)
                                
                           
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 59)
                        .background(Color(red: 1.0, green: 0.176, blue: 0.176))
                        .cornerRadius(14)
                        .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.5), radius: 20, x: 0, y: 0)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
                }
            }
        }
    }
}


struct OnboardingPage1: View {
    let screenWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
               
                Image("Container")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.81, height: screenWidth * 0.6)
                    .clipped()
                

                Text("Track What You Eat")
                    .font(.system(size: screenWidth * 0.081, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(0.406)
                    .multilineTextAlignment(TextAlignment.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, screenWidth * 0.1)
                    .padding(.top, screenWidth * 0.08)
                
        
                Text("Log meals and instantly see calories, protein, fats and carbs.")
                    .font(.system(size: screenWidth * 0.041, weight: .regular))
                    .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))
                    .lineSpacing(10)
                    .multilineTextAlignment(TextAlignment.center)
                    .tracking(-0.312)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, screenWidth * 0.1)
                    .padding(.top, screenWidth * 0.03)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct OnboardingPage2: View {
    let screenWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                Image("div")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.81, height: screenWidth * 0.81)
                    .clipped()
  
                Text("See Your Daily Energy")
                    .font(.system(size: screenWidth * 0.071, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(0.406)
                    .multilineTextAlignment(TextAlignment.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, screenWidth * 0.1)
                    .padding(.top, screenWidth * 0.08)
                
              
                Text("Watch your calories and macros fill your energy meter during the day.")
                    .font(.system(size: screenWidth * 0.041, weight: .regular))
                    .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))
                    .lineSpacing(10)
                    .multilineTextAlignment(TextAlignment.center)
                    .tracking(-0.312)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.top, screenWidth * 0.04)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct OnboardingPage3: View {
    let screenWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                Image("div-2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.81, height: screenWidth * 0.72)
                    .clipped()

                Text("Start Fueling Your Body")
                    .font(.system(size: screenWidth * 0.081, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(0.406)
                    .multilineTextAlignment(TextAlignment.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, screenWidth * 0.1)
                    .padding(.top, screenWidth * 0.08)

                Text("Your body is your supercar. Set your goals and start tracking today.")
                    .font(.system(size: screenWidth * 0.041, weight: .regular))
                    .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722)) 
                    .lineSpacing(10)
                    .multilineTextAlignment(TextAlignment.center)
                    .tracking(-0.312)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, screenWidth * 0.1)
                    .padding(.top, screenWidth * 0.03)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(NutritionStore())
}

# UAV-Trajectory-Prediction
MSc Thesis focused on the detection of trajectory collisions with aircraft using the ADS-B signal with a simulated UAV intruder.

# Abstract

As the use cases of Unmanned Aerial Vehicles (UAVs) are increasing rapidly, there is a
growing need for National Airspace (NAS) integration. Before this can happen, UAVs that fly
Beyond Visual Line of Sight (BVLOS) require Detect and Avoid (DAA) capabilities to avoid
collisions with surrounding aircraft. Automatic Dependent Surveillance-Broadcast (ADS-B)
offers data periodically which can be used to create situational awareness and predict the future
state of an intruder aircraft. ADS-B data is gathered using a Software Defined Radio (SDR)
this information was decoded to create a log of real flight data.
An Interacting Multiple Model (IMM) is used to predict future positions of aircraft by
combining linear Kalman Filter models. Three variations of IMMs were examined: Constant
Velocity Constant Acceleration (CV-CA); Constant Velocity Constant Acceleration with 2D
Coordinated Turn (CV-CA-2DCT) and Constant Velocity Constant Acceleration with 3D
Coordinated Turn (CV-CA-3DCT). The IMM CV-CA-2DCT has the highest accuracy of
prediction when estimating real flight positional data.
Collisions are simulated with both static and dynamic intruders by the propagation of an
Intruder Protected Zone (IPZ) using IMM predictions.

# Implementation 

The implementation of the collision prediction system is divided into subsystems which
include:
• Acquiring and decoding ADS-B data for each flight detected.
  ![image](https://github.com/user-attachments/assets/cfd12ac7-945d-4a09-90df-f4f58889135d)
  
• Building state prediction models based on linear state dynamics and combining linear
models with an IMM, Interacting Multiple Model.
  ![image](https://github.com/user-attachments/assets/f7b19a92-4932-466f-875c-b6b28a75700d)

• Simulation of static and dynamic intruders on the flight path that breaches the defined
IPZ ,Intruder Protected Zone, to determine the time to a collision.
  ![image](https://github.com/user-attachments/assets/d2a4c109-ba2f-426d-9081-e6ca9ec85f9f)


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
  A simplified version of the data acquisition system is seen below, the periodically
  broadcast ADS-B signal of surrounding aircraft is received via a telescopic dipole antenna
  connected to the SDR receiver. The SDR communicates with the Raspberry PI for radio wave
  access, decoding is done via Dump1090, a Mode S ES decoder, operating on PiAware client
  software. The decoded ADS-B data is pushed to an ADS-B database after each read cycle, this
  information is made available on port 8080 of the Raspberry Pi’s local IP address. The decoded
  data which is shared on port 8080 is pulled via an HTTP read within MATLAB. The port is
  periodically read at a rate of 1Hz to flight data contained in each time frame. This data is
  converted into appropriate units and is stored as a flight object for each unique ICAO callsign. 
  ![image](https://github.com/user-attachments/assets/cfd12ac7-945d-4a09-90df-f4f58889135d)
  
• Building state prediction models based on linear state dynamics and combining linear
  models with an IMM, Interacting Multiple Model.
  To predict the trajectory of an aircraft moving with linear dynamics, 3 motion models were
  considered for testing, the first model Constant Velocity (CV) considers the aircraft moving at
  a constant speed in the X, Y and Z-axis. The second model Constant Acceleration (CA)
  considers the aircraft manoeuvring about all axes. Two variations of turn models are
  constructed, a Coordinated Turn (CT) 2D which assumes the aircraft executes turns at a
  constant angular rate of change about the Z-axis and a CT 3D model in which turns are executed
  about all axes.
  ![image](https://github.com/user-attachments/assets/f7b19a92-4932-466f-875c-b6b28a75700d)
  
 • Variations of these models are combined using an IMM. The IMM variations are tested to
  determine which produces the most accurate predictions, which include:
  • IMM-CV-CA fuses the modes of CV and CA to produce position predictions when an
    aircraft switches between non-manoeuvring and manoeuvring states.
  • IMM-CV-CA-CT2D, which adds to the IMM-CV-CA model by adding a turn
    component about the Z-axis with a constant turn rate.
  • IMM-CV-CA-CT3D, which adds tracking for circular motion models in X, Y and Z
    with a constant turn rate. 

• Simulation of static and dynamic intruders on the flight path that breaches the defined
  IPZ ,Intruder Protected Zone, to determine the time to a collision.
  Size of the simulated IPZ can be seen below:
  ![image](https://github.com/user-attachments/assets/711cab9a-0654-4a85-b4f0-9762fd33c7e0)

  ![image](https://github.com/user-attachments/assets/d2a4c109-ba2f-426d-9081-e6ca9ec85f9f)

  ![image](https://github.com/user-attachments/assets/1a749a61-1510-4de9-bb38-ecc4e179d30c)

  ![image](https://github.com/user-attachments/assets/f525e672-e568-48b2-ac24-6f0ef7b12cea)


• Collision Alerts are defined by the following proceedure 
  ![image](https://github.com/user-attachments/assets/af0417f5-9c1b-4a92-813c-4fd860a0dde9)



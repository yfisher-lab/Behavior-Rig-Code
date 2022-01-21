from Phidget22.Phidget import *
from Phidget22.Devices.VoltageOutput import *
import time

def main():
	voltageOutput0 = VoltageOutput()
	voltageOutput1 = VoltageOutput()
	voltageOutput2 = VoltageOutput()
	voltageOutput3 = VoltageOutput()

	voltageOutput0.setChannel(0)
	voltageOutput1.setChannel(1)
	voltageOutput2.setChannel(2)
	voltageOutput3.setChannel(3)

	voltageOutput0.openWaitForAttachment(5000)
	voltageOutput1.openWaitForAttachment(5000)
	voltageOutput2.openWaitForAttachment(5000)
	voltageOutput3.openWaitForAttachment(5000)

	voltageOutput0.setVoltage(4)
	voltageOutput1.setVoltage(4)
	voltageOutput2.setVoltage(4)
	voltageOutput3.setVoltage(4)

	try:
		input("Press Enter to Stop\n")
	except (Exception, KeyboardInterrupt):
		pass

	voltageOutput0.close()
	voltageOutput1.close()
	voltageOutput2.close()
	voltageOutput3.close()

main()

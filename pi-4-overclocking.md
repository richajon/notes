# PI 4 Overclocking

## Verification tools

### Check the current frequency
```
vcgencmd measure_clock arm
```

### Stress the CPU
```
sudo apt install stress
stress --cpu 4
```


## Overclocking by editing `/boot/config.txt`
```
sudo nano /boot/config.txt
```

### Overclocking to 1750Mhz
```
over_voltage=2
arm_freq=1750
```

### Overclocking to 2000Mhz
```
over_voltage=6
arm_freq=2000
```

Links
https://magpi.raspberrypi.org/articles/how-to-overclock-raspberry-pi-4

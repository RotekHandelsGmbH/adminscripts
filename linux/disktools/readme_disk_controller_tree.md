# 🧹 Disk-to-Controller Tree Visualizer

> Group and display disks by controller with detailed metadata and SMART status.

---

## 📜 Overview

This Bash script helps visualize how disks are connected to your system, grouped by their **storage controllers**. It works with both **SATA/SAS** and **NVMe** drives and provides rich details including:

- 📂 Model, size, interface type
- 🧠 SMART health status
- 🌡️ Drive temperature
- 🔢 Serial number & 🔧 Firmware version
- 🧹 Link speed and protocol

---

## 🚀 Usage

```bash
chmod +x disk_controller_tree.sh
sudo ./disk_controller_tree.sh
```

> 🔐 Requires root privileges to access SMART and hardware information.

---

## 📦 Dependencies

The script checks for and installs these if missing:

- `smartmontools`
- `nvme-cli`

---

## 🧠 Example Output

```
╔═══════════════════════════════════════════════════════════════════════════════════════╗
║ 🧩  Disk-to-Controller Tree Visualizer                                                ║
║ 👤  Author : bitranox                                                                 ║
║ 🏛️  License: MIT                                                                      ║
║ 💾  Shows disks grouped by controller with model, size, interface, link speed,        ║
║     SMART status, drive temperature, serial number, and firmware revision             ║
╚═══════════════════════════════════════════════════════════════════════════════════════╝

🔍 Checking dependencies...
🧮 Scanning SATA disks...
⚡ Scanning NVMe disks...
📤 Preparing output...
🎯 0000:09:00.0 00.0 SATA controller: Marvell Technology Group Ltd. 88SE9128 PCIe SATA 6 Gb/s RAID controller with HyperDuo (rev 11)
  └── 💾 /dev/sdo  (ATA      Crucial_CT1050MX, 978.1G, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 40°C, 🔢 SN: 174719C858F2, 🔧 FW: M0CR070

🎯 0000:06:00.0 00.0 SCSI storage controller: OCZ Technology Group, Inc. RevoDrive 3 X2 PCI-Express SSD 240 GB (Marvell Controller) (rev 02)
  └── 💾 /dev/sdp  (ATA      OCZ-REVODRIVE3 X, 111.8G, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 30°C, 🔢 SN: OCZ-VFK995Y9E6R01U9T, 🔧 FW: 2.25
  └── 💾 /dev/sdq  (ATA      OCZ-REVODRIVE3 X, 111.8G, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 30°C, 🔢 SN: OCZ-001L4W1REALAX9YF, 🔧 FW: 2.25
  └── 💾 /dev/sdr  (ATA      OCZ-REVODRIVE3 X, 111.8G, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 30°C, 🔢 SN: OCZ-IK22O2N47ZEQB030, 🔧 FW: 2.25
  └── 💾 /dev/sds  (ATA      OCZ-REVODRIVE3 X, 111.8G, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 30°C, 🔢 SN: OCZ-338Z0A49W6BF91R6, 🔧 FW: 2.25

🎯 0000:04:00.0 00.0 Serial Attached SCSI controller: Broadcom / LSI SAS3008 PCI-Express Fusion-MPT SAS-3 (rev 02)
  └── 💾 /dev/sdg  (ATA      Samsung SSD 870 ,  3.6T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S6BCNX0T301951J, 🔧 FW: SVT02B6Q
  └── 💾 /dev/sdh  (ATA      Samsung SSD 870 ,  3.6T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S758NX0X703628F, 🔧 FW: SVT03B6Q
  └── 💾 /dev/sdi  (ATA      Samsung SSD 870 ,  3.6T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 34°C, 🔢 SN: S758NX0X500291P, 🔧 FW: SVT03B6Q
  └── 💾 /dev/sdj  (ATA      Samsung SSD 860 ,  3.6T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 31°C, 🔢 SN: S3YPNW0NC00984F, 🔧 FW: RVT04B6Q
  └── 💾 /dev/sdk  (ATA      Hitachi HUA72302,  1.8T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 43°C, 🔢 SN: YFHKTB3B, 🔧 FW: MK7OA840
  └── 💾 /dev/sdl  (ATA      WDC WD2002FYPS-0,  1.8T, SATA, 🧩 link=3.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 40°C, 🔢 SN: WD-WMAVY0138230, 🔧 FW: 04.01G02
  └── 💾 /dev/sdm  (ATA      Samsung SSD 870 ,  3.6T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S758NX0X700564Z, 🔧 FW: SVT03B6Q
  └── 💾 /dev/sdn  (ATA      Samsung SSD 870 ,  3.6T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S6BCNX0T301894V, 🔧 FW: SVT02B6Q

🎯 0000:00:1f.2 1f.2 SATA controller: Intel Corporation C600/X79 series chipset 6-Port SATA AHCI Controller (rev 06)
  └── 💾 /dev/sda  (ATA      Hitachi HDS72202,  1.8T, SATA, 🧩 link=3.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 43°C, 🔢 SN: JK11H1B9HTZGBR, 🔧 FW: JKAOA3MA
  └── 💾 /dev/sdb  (ATA      Hitachi HDS72302,  1.8T, SATA, 🧩 link=6.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 39°C, 🔢 SN: MN1210FA11PJ5D, 🔧 FW: MN6OAA10
  └── 💾 /dev/sdc  (ATA      Hitachi HDS72202,  1.8T, SATA, 🧩 link=3.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 42°C, 🔢 SN: JK1101B9H3LMNF, 🔧 FW: JKAOA3MA
  └── 💾 /dev/sdd  (ATA      Hitachi HDS72302,  1.8T, SATA, 🧩 link=3.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 36°C, 🔢 SN: MN1270FA0WSAJD, 🔧 FW: MN6OAA10
  └── 💾 /dev/sde  (ATA      Hitachi HDS72202,  1.8T, SATA, 🧩 link=3.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 44°C, 🔢 SN: JK11H1B9HTW45R, 🔧 FW: JKAOA3MA
  └── 💾 /dev/sdf  (ATA      Hitachi HDS72202,  1.8T, SATA, 🧩 link=3.0 Gb/s, ❤️ SMART: ✅ , 🌡️ 45°C, 🔢 SN: JK11H1B9HPDYHR, 🔧 FW: JKAOA3MA```
```

---

## 🧠 Example Output NvME

```
╔═══════════════════════════════════════════════════════════════════════════════════════╗
║ 🧩  Disk-to-Controller Tree Visualizer                                                ║
║ 👤  Author : bitranox                                                                 ║
║ 🏛️  License: MIT                                                                      ║
║ 💾  Shows disks grouped by controller with model, size, interface, link speed,        ║
║     SMART status, drive temperature, serial number, and firmware revision             ║
╚═══════════════════════════════════════════════════════════════════════════════════════╝

🔍 Checking dependencies...
🧮 Scanning SATA disks...
⚡ Scanning NVMe disks...
📤 Preparing output...
🎯 00:17.0 Intel Corporation Alder Lake-S PCH SATA Controller [AHCI Mode] (rev 11)
  └── 💾 /dev/sda  (Samsung SSD 870, 3.6T, SATA6, 🧩 link=SATA6, ❤️ SMART: ✅ , 🌡️ 34°C, 🔢 SN: S758NS0X600195F, 🔧 FW: SVT03B6Q)
  └── 💾 /dev/sdb  (Samsung SSD 870, 3.6T, SATA6, 🧩 link=SATA6, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S758NX0X703692J, 🔧 FW: SVT03B6Q)
  └── 💾 /dev/sdc  (Samsung SSD 870, 3.6T, SATA6, 🧩 link=SATA6, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S758NX0X213593X, 🔧 FW: SVT03B6Q)
  └── 💾 /dev/sdd  (Samsung SSD 870, 3.6T, SATA6, 🧩 link=SATA6, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S758NS0X600166B, 🔧 FW: SVT03B6Q)

🎯 03:00.0 Samsung Electronics Co Ltd NVMe SSD Controller PM9A1/PM9A3/980PRO
  └── 💾 /dev/nvme0n1  Samsung SSD 980 PRO 2TB, 1.8T, NVMe, 🧩 link=PCIe 16.0 GT/s PCIe x4, ❤️ SMART: ✅ , 🌡️ 41°C, 🔢 SN: S69ENF0R202846D, 🔧 FW: 2B2QGXA7

🎯 04:00.0 Seagate Technology PLC FireCuda 530 SSD (rev 01)
  └── 💾 /dev/nvme1n1  Seagate FireCuda 530 ZP4000GM30013, 3.6T, NVMe, 🧩 link=PCIe 16.0 GT/s PCIe x4, ❤️ SMART: ✅ , 🌡️ 36°C, 🔢 SN: 7VS012NA, 🔧 FW: SU6SM005

🎯 06:00.0 Seagate Technology PLC FireCuda 530 SSD (rev 01)
  └── 💾 /dev/nvme2n1  Seagate FireCuda 530 ZP4000GM30013, 3.6T, NVMe, 🧩 link=PCIe 16.0 GT/s PCIe x4, ❤️ SMART: ✅ , 🌡️ 39°C, 🔢 SN: 7VS00Z0B, 🔧 FW: SU6SM005

🎯 0a:00.0 ASMedia Technology Inc. ASM1062 Serial ATA Controller (rev 02)
  └── 💾 /dev/sde  (Samsung SSD 870, 931.5G, SATA6, 🧩 link=SATA6, ❤️ SMART: ✅ , 🌡️ 33°C, 🔢 SN: S75CNX0X339421R, 🔧 FW: SVT03B6Q)

🎯 11:00.0 Seagate Technology PLC FireCuda 530 SSD (rev 01)
  └── 💾 /dev/nvme3n1  Seagate FireCuda 530 ZP4000GM30013, 3.6T, NVMe, 🧩 link=PCIe 8.0 GT/s PCIe x4, ❤️ SMART: ✅ , 🌡️ 38°C, 🔢 SN: 7VS00XFD, 🔧 FW: SU6SM005

🎯 12:00.0 Seagate Technology PLC FireCuda 530 SSD (rev 01)
  └── 💾 /dev/nvme4n1  Seagate FireCuda 530 ZP4000GM30013, 3.6T, NVMe, 🧩 link=PCIe 16.0 GT/s PCIe x4, ❤️ SMART: ✅ , 🌡️ 36°C, 🔢 SN: 7VS00XN2, 🔧 FW: SU6SM005
```

---

## 👤 Author

**bitranox**

---

## 🏩 License

MIT License


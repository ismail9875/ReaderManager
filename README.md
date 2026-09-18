ReaderManager — إضافة إدارة قارئات OSCam و NCam لأجهزة Enigma2

<p align="center">
  <img src="https://img.shields.io/badge/Enigma2-Plugin-blue" alt="Enigma2 Plugin">
  <img src="https://img.shields.io/badge/Python-2.7%20%7C%203.x-green" alt="Python">
  <img src="https://img.shields.io/badge/License-GPL--3.0-orange" alt="License">
  <img src="https://img.shields.io/badge/Version-1.0-brightgreen" alt="Version">
</p>

---

📖 نظرة عامة

ReaderManager هي إضافة متكاملة لأجهزة Enigma2 تُتيح لك إدارة قارئات OSCam و NCam مباشرة من واجهة رسومية أنيقة، دون الحاجة للتعامل مع الملفات النصية أو سطر الأوامر.

تجمع الإضافة بين:

· إدارة القراء (Readers) عبر WebIF الخاص بـ OSCam/NCam
· إدارة المحاكيات (Emulators) المثبتة على /usr/bin
· تحرير ملفات الإعدادات (oscam.server / ncam.server) بواجهة مبسّطة
· عرض تفاصيل البطاقات والـ CAIDs والـ Providers

كل ذلك عبر واجهة عصرية بتصميم داكن مريح للعين، ومناسبة لأجهزة الريموت كنترول.

---

✨ الخصائص الرئيسية

🎛️ إدارة القراء (Readers Manager)

الخصائص الوصف
عرض جدول القراء Label / Host / Port / ON-OFF / Protocol / Cards / Status في جدول واحد
التبديل السريع زر OK لتبديل حالة القارئ (ON ↔ OFF)
إضافة قارئ جديد زر Green لفتح نموذج إضافة قارئ كامل
حذف قارئ زر Yellow لحذف القارئ المحدد
تحرير قارئ زر Blue لتعديل إعدادات القارئ الحالي
التنقل الدائري عند الوقوف على أول/آخر قارئ، السكرول يعود للطرف الآخر تلقائياً
التبديل بين OSCam/NCam أسهم يمين/يسار للتبديل بين الملفين
عرض تفاصيل القارئ زر Info لفتح شاشة تفاصيل شاملة

🔧 إدارة المحاكيات (Emulator Manager)

الخصائص الوصف
اكتشاف تلقائي مسح /usr/bin لاكتشاف كل المحاكيات (OSCam / NCam)
استخراج النسخة من اسم الملف أو تنفيذ -V أو من ملفات /tmp
إيجاد سكربت init يبحث في /etc/init.d/softcam.<name>-<version> تلقائياً
التحكم الفردي Start/Stop لكل محاكٍ على حدة
إعادة التشغيل زر Restart للمحاكي المحدد فقط
محاكي واحد نشط عند تشغيل محاكٍ، تُوقَف كل المحاكيات الأخرى تلقائياً
عرض الحالة RUNNING / STOPPED لكل محاكٍ

📝 محرر القراء (Reader Editor)

· وضعان: Simple (حقول أساسية) و Advanced (كل الحقول)
· إخفاء تلقائي للكلمات السرية والمفاتيح (*****)
· مساعدة لكل حقل عند الضغط على Info
· تحقق فوري من صحة البيانات قبل الحفظ
· دعم كل البروتوكولات: cccam, newcamd, mgcamd, cs378x, camd35, gbox, radegast, mouse, smartreader, pcsc, internal, constcw, cacheex, emu

🎬 شاشة تفاصيل القارئ (Reader View)

· عرض كل الـ CAIDs مقسّمة حسب النظام (Viaccess, Irdeto, Conax...)
· عرض Providers لكل CAID مع عدد البطاقات
· ألوان مميزة لكل نظام تشفير
· تنقل بين الأعمدة والصفوف عبر الأسهم
· أزرار سريعة: Close / ON-OFF / Edit / Delete

---

📸 لقطات الشاشة

شاشة ReaderManager الرئيسية

```
┌─────────────────────────────────────────────────────────────────┐
│  Reader Manager                                     [OSCAM LOGO]│
├─────────────────────────────────────────────────────────────────┤
│  Label      Host      Port   ON/OFF  Protocol  Cards   Status   │
├─────────────────────────────────────────────────────────────────┤
│  emulator   *****     0      ON      emu       -       -        │
│  server1    *****     12000  ON      cccam     3       CONNECTED│
│  server2    *****     34000  OFF     newcamd   -       -        │
├─────────────────────────────────────────────────────────────────┤
│  [ Exit ]    [ Add ]    [ Delete ]    [ Edit ]                  │
└─────────────────────────────────────────────────────────────────┘
```

شاشة Emulator Manager

```
┌─────────────────────────────────────────────────────────────────┐
│  Emulator Manager                                  2/3 running  │
├─────────────────────────────────────────────────────────────────┤
│  Name           Family   Version   Init Script    State         │
├─────────────────────────────────────────────────────────────────┤
│  oscam-11966    OSCAM    11966     softcam.os...  RUNNING       │
│  oscam-11718    OSCAM    11718     softcam.os...  STOPPED       │
│  ncam-13.5      NCAM     13.5      softcam.nc...  STOPPED       │
├─────────────────────────────────────────────────────────────────┤
│  [ Close ]    [ Start/Stop ]    [ Refresh ]    [ Restart ]      │
└─────────────────────────────────────────────────────────────────┘
```

---

🚀 التثبيت

الطريقة الأولى: أمر واحد (موصى بها)

```bash
wget -qO- https://raw.githubusercontent.com/ismail9875/ReaderManager/main/install.sh | sh
```

الطريقة الثانية: يدوياً

```bash
# 1. تنزيل الأرشيف
cd /tmp
wget --no-check-certificate -O ReaderManager.tar.gz \
  "https://github.com/ismail9875/ReaderManager/raw/refs/heads/main/ReaderManager.tar.gz"

# 2. الاستخراج
tar -xzf ReaderManager.tar.gz -C /tmp/

# 3. النسخ إلى مسار الإضافات
mkdir -p /usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager
cp -a /tmp/OscamReaderManager/* \
      /usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager/

# 4. الصلاحيات
chmod -R 755 /usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager

# 5. إعادة تشغيل Enigma2
init 4 && init 3
```

الطريقة الثالثة: عبر سكريبت التثبيت الآلي

نزّل ملف install_reader_manager.sh من المستودع وشغّله:

```bash
sh /tmp/install_reader_manager.sh
```

---

🎮 طريقة الاستخدام

فتح الإضافة

Main Menu → Plugins → Readers Manager

أو:

Main Menu → Extensions → Readers Manager Settings

جدول الأزرار (ReaderManager)

الزر الوظيفة
OK تبديل حالة القارئ (ON ↔ OFF) + إعادة تشغيل SoftCam
Red خروج
Green إضافة قارئ جديد
Yellow حذف القارئ المحدد
Blue تحرير القارئ المحدد
Menu فتح قائمة الإعدادات
Info عرض تفاصيل القارئ (CAIDs / Providers)
EPG عرض سجل التصحيح (Debug Log)
Left / Right التبديل بين OSCam / NCam
Up / Down التنقل بين القراء (مع سكرول دائري)

جدول الأزرار (Emulator Manager)

الزر الوظيفة
OK / Green Start / Stop للمحاكي المحدد
Blue إعادة تشغيل المحاكي المحدد
Yellow إعادة مسح /usr/bin
Red خروج
Up / Down التنقل بين المحاكيات (سكرول دائري)

---

⚙️ الإعدادات

General Settings

الإعداد الخيارات
Poll Interval 3 - 120 ثانية
Sort readers أبجدي / ترتيب الملف
Editor Mode Simple / Advanced
Auto restart after changes نعم / لا
Restart delay فوري / 1s / 3s / 5s / 10s
Confirm before restart نعم / لا

OSCam WebIF Settings

الإعداد الوصف
Enable تفعيل/تعطيل OSCam API
Auto-detect كشف تلقائي من oscam.version
WebIF URL مثل http://127.0.0.1:8888
Username / Password بيانات الدخول
Timeout 1 - 30 ثانية

NCam WebIF Settings

نفس الخيارات مع عنوان افتراضي http://127.0.0.1:8181.

---

🌍 البروتوكولات المدعومة

البروتوكول الوصف
cccam شبكة CCcam
newcamd Newcamd مع DES key
mgcamd MgCamd (NCam فقط)
cs378x Cache-Exchange TCP
camd35 Camd 3.5
gbox GBox
radegast Radegast
mouse قارئ بطاقات تسلسلي/USB
smartreader Smargo / SmartReader
pcsc PC/SC reader
internal قارئ داخلي (DreamBox)
constcw ملف CW ثابت
cacheex Cache-Exchange
emu محاكي (SoftCam.Key)

---

🔒 الأمان

· إخفاء تلقائي لـ Password / DES Key / AES Key / PIN
· نسخ احتياطية تلقائية (.bak) قبل كل كتابة
· كتابة ذرّية (atomic write) لمنع تلف الملفات
· تحقق مزدوج بعد الكتابة (يقرأ الملف مرة أخرى للتأكد)
· لا يُرسل أي بيانات لجهات خارجية

---

🗂️ بنية الملفات

```
/usr/lib/enigma2/python/Plugins/Extensions/OscamReaderManager/
├── __init__.py
├── plugin.py              ← نقطة الدخول الرئيسية
├── reader_parser.py       ← تحليل/كتابة ملفات .server
├── reader_dialog.py       ← محرر القارئ
├── reader_view.py         ← شاشة تفاصيل القارئ
├── oscamapi.py            ← عميل OSCam WebIF
├── ncamapi.py             ← عميل NCam WebIF
├── emu_manager.py         ← إدارة المحاكيات من /usr/bin
├── test_queue.py          ← طابور اختبار القراء
├── restart_oscam.py       ← إعادة تشغيل OSCam
├── restart_ncam.py        ← إعادة تشغيل NCam
├── field_help.py          ← قاعدة بيانات مساعدة الحقول
├── logger.py              ← التسجيل
├── paths.py               ← إدارة المسارات
├── images/
│   ├── oscam.png
│   ├── ncam.png
│   └── plugin.png
└── cache/
    └── restart_methods.json  ← الطرق الناجحة لإعادة التشغيل
```

---

🛠️ المتطلبات

المتطلب النسخة
Enigma2 أي إصدار حديث
Python 2.7 أو 3.x
OSCam أو NCam أي إصدار حديث
مساحة ~2 MB
نظام DreamOS، OpenATV، OpenPLi، OpenVision، BlackHole، ...

---

🐛 حل المشاكل

الإضافة لا تظهر في القائمة

```bash
init 4 && init 3
```

OSCam WebIF لا يستجيب

1. افتح Settings → OSCam WebIF Settings
2. اضغط Yellow لاختبار الاتصال
3. تحقق من:
   · عنوان WebIF (http://127.0.0.1:8888)
   · اسم المستخدم وكلمة المرور
   · أن WebIF مفعّل في oscam.conf

المحاكي لا يُكتشف

```bash
# تحقق من وجود الملفات الثنائية
ls -la /usr/bin/oscam* /usr/bin/ncam*

# تحقق من سكربتات init
ls -la /etc/init.d/softcam.*
```

فشل إعادة التشغيل التلقائي

افتح شاشة Debug Log لرؤية تفاصيل المحاولات. الطريقة الناجحة تُحفظ في cache/restart_methods.json.

---

📊 سجل التغييرات

v1.0 (الإصدار الحالي)

· ✅ إدارة قارئات OSCam و NCam
· ✅ إدارة محاكيات من /usr/bin
· ✅ استبعاد متبادل (محاكي واحد نشط)
· ✅ محرر قارئ مع Simple/Advanced
· ✅ شاشة تفاصيل القارئ مع CAIDs و Providers
· ✅ إعادة تشغيل ذكية بأربع طرق
· ✅ إخفاء البيانات الحساسة
· ✅ نسخ احتياطية تلقائية
· ✅ سكرول دائري في القوائم

---

🤝 المساهمة

المساهمات مرحّب بها! يمكنك:

1. عمل Fork للمستودع
2. إنشاء فرع جديد: git checkout -b feature/my-feature
3. الالتزام بالتغييرات: git commit -am 'Add new feature'
4. رفع الفرع: git push origin feature/my-feature
5. فتح Pull Request

معايير الكود

· توافق Python 2.7 / 3.x
· استخدام from __future__ import في كل ملف
· لا تعتمد على مكتبات خارجية (كل شيء من Enigma2)
· التعليقات بالعربية أو الإنجليزية
· اختبار على جهاز حقيقي قبل الـ PR

---

📄 الترخيص

هذا المشروع مرخّص تحت GPL-3.0 — راجع ملف LICENSE للتفاصيل.

---

🙏 شكر خاص

· فريق OSCam على البروتوكول الرائع
· فريق NCam على الدعم المستمر
· مجتمع Enigma2 على الأدوات والمساعدات
· كل من ساهم في اختبار الإضافة

---

📞 التواصل

القناة الرابط
GitHub ismail9875/ReaderManager
Issues Report a bug
Discussions Ask questions

---

<p align="center">
  <b>ReaderManager</b> — إدارة احترافية لقارئات OSCam و NCam على Enigma2<br>
  <i>صُنع بـ ❤️ لمجتمع Enigma2 العربي</i>
</p>

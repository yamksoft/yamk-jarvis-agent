# خطة تنفيذ: واجهة إعدادات التكوين (محلي / سحابي)

بناءً على طلبك، قمت بتحليل الملفات لفهم بنية المشروع وتحديد أفضل طريقة لإضافة ميزة تكوين الاتصال (Local / Cloud) من خلال واجهة المستخدم مع حفظ الإعدادات والتحكم التلقائي في حاويات Docker.

## User Review Required

> [!WARNING]
> لإيقاف وتشغيل الحاويات (مثل إيقاف `livekit-server` عند اختيار الاتصال السحابي) من داخل واجهة Next.js (الموجودة بداخل حاوية `jarvis-app`)، يجب منح الحاوية صلاحية الوصول إلى محرك Docker الخاص بالجهاز المضيف (Host). 
> للقيام بذلك، سنحتاج إلى عمل Mount لملف `docker.sock` وجعل الحاوية تعمل بصلاحيات `root`. هل أنت موافق على هذا الإجراء لإتاحة التحكم التلقائي؟

> [!IMPORTANT]
> بما أنك طلبت حفظ التكوينات في ملفات `env` متعددة (`.env.local` و `.env.cloud`)، سأقوم ببرمجة الواجهة الخلفية (Backend - Python) لتقرأ الوضع النشط (Active Mode) من ملف نصي صغير وتُحمل إما `.env.local` أو `.env.cloud` بناءً على اختيار المستخدم لتجنب التداخل.

## Proposed Changes

### الواجهة الأمامية (Frontend)

#### [NEW] [page.tsx](file:///C:/C:\yamk-jarvis-agent/jarvis/frontend/app/setup/page.tsx)
إنشاء صفحة إعدادات جديدة بتصميم عصري (باستخدام TailwindCSS و Shadcn) تتيح للمستخدم:
- اختيار نوع الاتصال (Local Offline Mode أو Cloud Online Mode).
- إدخال المفاتيح والروابط الخاصة بكل وضع.
- زر لحفظ وتطبيق الإعدادات تلقائياً.

#### [NEW] [route.ts](file:///C:/C:\yamk-jarvis-agent/jarvis/frontend/app/api/setup/route.ts)
إنشاء نقطة اتصال (API Route) في Next.js تقوم بالتالي:
1. استلام البيانات من صفحة الإعدادات.
2. الكتابة فوق ملفات `.env.local` أو `.env.cloud` في كلا المسارين (Frontend و Backend).
3. كتابة الوضع الحالي في ملف `active_mode.txt` ليعرفه وكيل بايثون.
4. إيقاف حاوية `livekit-server` (عن طريق Docker CLI) إذا كان الوضع سحابياً، أو تشغيلها إذا كان محلياً.
5. إعادة تشغيل عملية بايثون (عبر `supervisorctl restart backend`) لتطبيق المتغيرات الجديدة فوراً.

### الواجهة الخلفية (Backend)

#### [MODIFY] [agent.py](file:///C:/C:\yamk-jarvis-agent/jarvis/src/agent.py)
تعديل كود البايثون ليقوم بالتالي عند بدء التشغيل:
- قراءة ملف `active_mode.txt` لمعرفة الوضع الحالي (local أو cloud).
- استخدام `load_dotenv` لتحميل الملف الصحيح (`.env.local` أو `.env.cloud`) بدلاً من تحميل `.env.local` بشكل ثابت.

### إعدادات الحاويات (Docker & Compose)

#### [MODIFY] [docker-compose.yml](file:///C:/C:\yamk-jarvis-agent/docker-compose.yml)
- تغيير صلاحيات ملفات `.env` المحمولة (Volumes) من قراءة فقط `ro` إلى قراءة وكتابة `rw`.
- إضافة مجلد `/var/run/docker.sock` كـ Volume لتمكين التحكم في الحاويات الأخرى.
- تشغيل الحاوية بصلاحيات `root` لتمكينها من استخدام Docker Socket والتعديل على الملفات بأمان.

#### [MODIFY] [Dockerfile](file:///C:/C:\yamk-jarvis-agent/jarvis/Dockerfile)
- إضافة تثبيت `docker.io` (Docker CLI) داخل الحاوية النهائية حتى يتمكن الـ API الخاص بـ Next.js من تنفيذ أوامر `docker stop` و `docker start` بسهولة.
- إزالة المستخدم `appuser` وتشغيل العمليات كـ `root` لتمكين استخدام Docker Socket.

## Verification Plan

### Manual Verification
1. بعد تطبيق الكود، سيُطلب منك إعادة بناء الحاويات `docker compose build` وتشغيلها.
2. الدخول إلى صفحة الإعدادات `http://localhost:3000/setup`.
3. اختيار الوضع "Cloud" وإدخال البيانات الوهمية والتأكيد.
4. التأكد من أن حاوية `livekit-server` توقفت تلقائياً في Docker Desktop.
5. التأكد من أن ملفات `.env.cloud` في مشروعك قد تم تحديثها بالفعل بالبيانات المدخلة.

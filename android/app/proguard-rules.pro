# === Existing rules ===
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }
-keep class com.google.api.client.** { *; }
-keep class org.joda.time.** { *; }

# === NEW rules ===

# Joda-Convert
-keep class org.joda.convert.** { *; }

# GSS (Kerberos)
-keep class org.ietf.jgss.** { *; }

# Naming (LDAP, SSL)
-keep class javax.naming.** { *; }
-keep class javax.naming.directory.** { *; }
-keep class javax.naming.ldap.** { *; }

# Suppress warnings
-dontwarn javax.naming.**
-dontwarn org.ietf.jgss.**
-dontwarn org.joda.convert.**

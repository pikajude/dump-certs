#import <Foundation/Foundation.h>

NSMutableArray * fetchPEMRoots() {
  SecTrustSettingsDomain domains[] = {
    kSecTrustSettingsDomainSystem,
    kSecTrustSettingsDomainAdmin,
    kSecTrustSettingsDomainUser
  };

  NSMutableArray *arr = [NSMutableArray array];

  int numDomains = sizeof(domains) / sizeof(SecTrustSettingsDomain);

  for(int i = 0; i < numDomains; i++) {
    CFArrayRef certs = NULL;
    OSStatus err = SecTrustSettingsCopyCertificates(domains[i], &certs);
    if(err != noErr) {
      continue;
    }

    long numCerts = CFArrayGetCount(certs);
    for(long j = 0; j < numCerts; j++) {
      CFDataRef data = NULL;
      CFErrorRef errRef = NULL;
      SecCertificateRef cert = (SecCertificateRef)CFArrayGetValueAtIndex(certs, j);
      if(cert == NULL) {
        continue;
      }

      CFDataRef subjectName = SecCertificateCopyNormalizedSubjectContent(cert, &errRef);
      if(errRef != NULL) {
        CFRelease(errRef);
        continue;
      }
      CFDataRef issuerName = SecCertificateCopyNormalizedIssuerContent(cert, &errRef);
      if(errRef != NULL) {
        CFRelease(subjectName);
        CFRelease(errRef);
        continue;
      }
      Boolean equal = CFEqual(subjectName, issuerName);
      CFRelease(subjectName);
      CFRelease(issuerName);
      if(!equal) {
        continue;
      }

      err = SecItemExport(cert, kSecFormatX509Cert, kSecItemPemArmour, NULL, &data);
      if(err != noErr) {
        continue;
      }

      [arr addObject:(__bridge NSMutableData*)data];
    }
    CFRelease(certs);
  }

  return arr;
}

int main(int argc, const char * argv[]) {
  for(NSMutableData *cert in fetchPEMRoots()) {
    char *buf = [cert mutableBytes];
    buf[[cert length]] = 0;
    printf("%s", buf);
  }
}

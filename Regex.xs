#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <regex.h>

#include "const-c.inc"

#define regpk     "__reg_pointer"
#define regpk_len 13

MODULE = POSIX::Regex   PACKAGE = POSIX::Regex		

INCLUDE: const-xs.inc

void
regcomp(self,regular,opts)
    SV   *self
    char *regular
    int  opts

    PREINIT:
    regex_t *r = (regex_t *) malloc(sizeof(regex_t));
    int err;
    char *errmsg[256];
    HV* me;

    if( r == NULL )
        croak("error allocating memory for regular");

    if( !sv_isobject(self) )
        croak("error trying to compile regular in an unblessed reference");

    me = (HV*) SvRV(self); // de-reference us
    if( SvTYPE(me) != SVt_PVHV )
        croak("error trying to compile regular in a blessed reference that isn't a hash reference");

    CODE:
    if( (err = regcomp(r, regular, opts)) != REG_NOERROR ) {
        regerror(err, r, (char *)errmsg, 250); // 255 or 256?  screw it, 250
        croak("error compiling regular expression, %s", errmsg);
    }

    // SV**  hv_store(HV*, const char* key, U32 klen, SV* val, U32 hash); // U32 hash is the pre-computed key (if you like)
    hv_store(me, regpk, regpk_len, newSVuv((unsigned int) r), 0);

    // warn("regcomp r=%d", (unsigned int)r);

void
cleanup_memory(self)
    SV *self

    PREINIT:
    regex_t *r;
    HV* me;

    if( !sv_isobject(self) )
        croak("error trying to compile regular in an unblessed reference");

    me = (HV*) SvRV(self); // de-reference us
    if( SvTYPE(me) != SVt_PVHV )
        croak("error trying to compile regular in a blessed reference that isn't a hash reference");

    // SV**  hv_fetch(HV*, const char* key, U32 klen, I32 lval); lval indicates whether this is part of a store operation also
    r = (regex_t *) SvUV(*(hv_fetch(me, regpk, regpk_len, 0)));

    CODE:
    // warn("DESTROY r=%d", (unsigned int)r);

    regfree(r); free(r);

int
regexec(self,string,opts)
    SV *self
    char *string
    int opts;

	PREINIT:
    regex_t *r;
    HV* me;
    int err;
    char *errmsg[256];

    if( !sv_isobject(self) )
        croak("error trying to compile regular in an unblessed reference");

    me = (HV*) SvRV(self); // de-reference us
    if( SvTYPE(me) != SVt_PVHV )
        croak("error trying to compile regular in a blessed reference that isn't a hash reference");

    // SV**  hv_fetch(HV*, const char* key, U32 klen, I32 lval); lval indicates whether this is part of a store operation also
    r = (regex_t *) SvUV(*(hv_fetch(me, regpk, regpk_len, 0)));

    CODE:
    err = regexec(r, string, 0, (regmatch_t *) NULL, opts); // | REG_NOSUB); // TODO: can't NOSUB here, that goes to regcomp!!

    if( err == REG_NOMATCH ) {
        RETVAL = 0;

    } else if( err ) {
        regerror(err, r, (char *)errmsg, 250); // 255 or 256?  screw it, 250
        croak("error compiling regular expression, %s", errmsg);

    } else {
        RETVAL = 1;
    }

    OUTPUT:
    RETVAL

AV*
regexec_wa(self,tomatch,opts)
    SV *self
    char *tomatch
    int opts;

	PREINIT:
    regex_t *r;
    HV* me;
    int err;
    char *errmsg[256];
    regmatch_t mat[10];
    int i,e,s;

    AV* retav = newAV();

    if( !sv_isobject(self) )
        croak("error trying to compile regular in an unblessed reference");

    me = (HV*) SvRV(self); // de-reference us
    if( SvTYPE(me) != SVt_PVHV )
        croak("error trying to compile regular in a blessed reference that isn't a hash reference");

    // SV**  hv_fetch(HV*, const char* key, U32 klen, I32 lval); lval indicates whether this is part of a store operation also
    r = (regex_t *) SvUV(*(hv_fetch(me, regpk, regpk_len, 0)));

    CODE:
    err = regexec(r, tomatch, 10, mat, opts);

    RETVAL = retav;

    if( err == REG_NOMATCH ) {
        // twiddle baby

    } else if( err ) {
        regerror(err, r, (char *)errmsg, 250); // 255 or 256?  screw it, 250
        croak("error compiling regular expression, %s", errmsg);

    } else {
        // find substrings and push them into retav
        for(i=0; i<10; i++) {
            s = mat[i].rm_so;
            e = mat[i].rm_eo;

            if( s==-1 || e==-1 ) {
                break;

            } else {
                av_push(retav, newSVpvn(tomatch+s, e-s));
            }
        }
    }

    OUTPUT:
    RETVAL

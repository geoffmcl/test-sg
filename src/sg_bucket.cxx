/*\
 * sg_bucket.cxx
 *
 * Copyright (c) 2015 - Geoff R. McLane
 * Licence: GNU GPL version 2
 *
\*/

#include <stdio.h>
#include <string.h> // for strdup(), ...
#include <string>
#include <vector>
#include <simgear/compiler.h>
#include <simgear/misc/sg_path.hxx>
#include <simgear/misc/sg_dir.hxx>
#include <simgear/io/sg_file.hxx>
#include <simgear/debug/logstream.hxx>
#include <simgear/bucket/newbucket.hxx>

#ifdef USE_TERRA_LIBS
// #include <Include/version.h>
#include <terragear/version.h>  // a static getTGVersion string
#include <terragear/tg_polygon.hxx>
#include <terragear/tg_chopper.hxx>
#include <terragear/tg_shapefile.hxx>
#endif // #ifdef USE_TERRA_LIBS

#include "sprtf.hxx"

static const char *module = "sg_bucket";

static double minlon, minlat, maxlon, maxlat;
static bool got_bbox = false;
static bool got_pos = false;
static double usr_lat, usr_lon;

static const char *xg_out = "tempbuck.xg";

void give_help( char *name )
{
    printf("%s: usage: [options]\n", module);
    printf("Options:\n");
    printf(" --help                       (-h or -?) = This help and exit(0)\n");
    printf(" --spat minlon minlat maxlon maxlat (-s) = Set spatial, ie bounding box\n");
    printf(" --pos lon lat                      (-p) = Set geo-position wsg84 degrees\n");

    // TODO: More help
}

static std::string get_bucket_path(SGBucket & b)
{
    std::string s(b.gen_base_path());
    s += "/";
    s += b.gen_index_str();
    return s;
}

void show_bucket(double lon, double lat)
{
    SGBucket b;
    b.set_bucket(lon, lat);
    SPRTF("%s: pos lon lat %lf %lf is in bucket '%s'\n", module,
        minlon, minlat, get_bucket_path(b).c_str());
}

bool in_world_range(double lat, double lon)
{
    if ((lon < -180.0) ||
        (lon > 180.0) ||
        (lat < -90.0) ||
        (lat > 90.0)) {
        return false;
    }
    return true;
}


int parse_args( int argc, char **argv )
{
    int i,i2,c;
    char *arg, *sarg;
    for (i = 1; i < argc; i++) {
        arg = argv[i];
        i2 = i + 1;
        if (*arg == '-') {
            sarg = &arg[1];
            while (*sarg == '-')
                sarg++;
            c = *sarg;
            switch (c) {
            case 'h':
            case '?':
                give_help(argv[0]);
                return 2;
                break;
            // TODO: Other arguments
            case 's':
                if ((i2 + 3) < argc) {
                    minlon = atof(argv[i2++]);
                    minlat = atof(argv[i2++]);
                    maxlon = atof(argv[i2++]);
                    maxlat = atof(argv[i2++]);
                    i = i2 - 1;
                    if (!in_world_range(minlat, minlon)) {
                        printf("%s: Error in min lon %lf, or lat %lf\n", module, minlon, minlat);
                        return 1;
                    }
                    if (!in_world_range(maxlat, maxlon)) {
                        printf("%s: Error in max lon %lf, or lat %lf\n", module, maxlon, maxlat);
                        return 1;
                    }
                    if (minlon >= maxlon) {
                        printf("%s: Error in min lon %lf GTE max lon %lf\n", module, minlon, maxlon);
                        return 1;
                    }
                    if (minlat >= maxlat) {
                        printf("%s: Error in min lat %lf GTE max lat %lf\n", module, minlat, maxlat);
                        return 1;
                    }
                    got_bbox = true;
                }
                else {
                    printf("Expect 4 wsg84 degrees - min_lon min_lat max_lon max_lat\n");
                    return 1;
                }
                break;
            case 'p':
                if ((i2 + 1) < argc) {
                    usr_lon = atof(argv[i2++]);
                    usr_lat = atof(argv[i2++]);
                    i = i2 - 1;
                    if (!in_world_range(usr_lat, usr_lon)) {
                        printf("%s: Error in lon %lf, or lat %lf\n", module, usr_lon, usr_lat);
                        return 1;
                    }
                    got_pos = true;
                }
                else {
                    printf("Expect 2 wsg84 degrees - usr_lon usr_lat\n");
                    return 1;
                }
            default:
                printf("%s: Unknown argument '%s'. Try -? for help...\n", module, arg);
                return 1;
            }
        } else {
            // bear argument
            printf("%s: What is this '%s'?\n", module, arg);
            return 1;
        }
    }
    if (!(got_bbox | got_pos)) {
        printf("%s: No work found in %d command!", module, argc - 1);
        return 1;
    }
    if (got_bbox) {
        printf("%s: Will show buckets in bbox %lf %lf %lf %lf\n", module,
            minlon, minlat, maxlon, maxlat);
    }
    if (got_pos) {
        show_bucket(usr_lon, usr_lat);
    }
    return 0;
}

typedef std::vector<SGBucket> vSGBList;
typedef vSGBList::iterator iSGB;

vSGBList buck_list;

int get_bucket_count(double min_lat, double max_lat, double min_lon, double max_lon)
{
    int buckets = 0;
    SGBucket b_cur;
    int dx, dy, i, j;
    buck_list.clear();

    SGBucket b_min(min_lon, min_lat);
    SGBucket b_max(max_lon, max_lat);
    if (b_min == b_max) {
        buck_list.push_back(b_min);
        return 1;
    }
    sgBucketDiff(b_min, b_max, &dx, &dy);
    // FIX20110920 - change dx from 2880 to 2887
    if ((dx > 2887) || (dy > 1440) || (dx < 0) || (dy < 0)) {
        static int _s_shown_error = 0;
        //if (_s_shown_error < 3) {
        if (!_s_shown_error) {
            _s_shown_error++;
            char * cp = GetNxtBuf();
            sprintf(cp, "Some stupid error on diffing two Buckets!\ndx=%d, dy=%d? (%d of 3)\n",
                dx, dy, _s_shown_error);
            sprintf(EndBuf(cp), "Limits: lat,lon MAX %.12f,%.12f, MIN %.12f,%.12f",
                max_lat, max_lon, min_lat, min_lon);
            sprtf("%s\n", cp);
            // MB2("BUCKET ERROR", cp);
        }
        return 0;
    }
    // iterate through the buckets...
    for (j = 0; j <= dy; j++) {
        for (i = 0; i <= dx; i++) {
            b_cur = sgBucketOffset(min_lon, min_lat, i, j);
            buck_list.push_back(b_cur);
            buckets++;
        }
    }
    return buckets;
}


void show_buckets_in_box()
{
    SGBucket b_min, b_max;
    SGGeod geod;
    b_min.set_bucket(minlon, minlat);
    b_max.set_bucket(maxlon, maxlat);

    SPRTF("%s: mins %lf %lf is in bucket '%s'\n", module,
        minlon, minlat, get_bucket_path(b_min).c_str());

    SPRTF("%s: maxs %lf %lf is in bucket '%s'\n", module,
        maxlon, maxlat, get_bucket_path(b_max).c_str());

    if (b_min != b_max) {
        int cnt = get_bucket_count(minlat, maxlat, minlon, maxlon);
        SPRTF("%s: Got %d buckets in bbox\n", module, cnt);
        char *cp = GetNxtBuf();
        std::string xg = "# all the buckets\n";
        for (int i = 0; i < cnt; i++) {
            b_min = buck_list[i];
            double span4 = b_min.get_width() / 4.0;
            SPRTF("%2d: %s\n", (i + 1), get_bucket_path(b_min).c_str());
            for (int j = 0; j < 4; j++) {
                geod = b_min.get_corner(j);
                sprintf(cp, "%lf %lf\n", geod.getLongitudeDeg(), geod.getLatitudeDeg());
                xg += cp;
            }
            geod = b_min.get_corner(0);
            sprintf(cp, "%lf %lf\n", geod.getLongitudeDeg(), geod.getLatitudeDeg());
            xg += cp;
            xg += "NEXT\n";
            geod = b_min.get_center();
            sprintf(cp,"anno %lf %lf %s\n", (geod.getLongitudeDeg() - span4), geod.getLatitudeDeg(),
                b_min.gen_index_str().c_str());
            xg += cp;
        }
        FILE *fp = fopen(xg_out, "w");
        if (fp) {
            cnt = fwrite(xg.c_str(), 1, xg.size(), fp);
            fclose(fp);
            SPRTF("%s: Written bucket xg to '%s'\n", module, xg_out);
        }
        else {
            SPRTF("%s: Failed to open xg file '%s'\n", module, xg_out);
        }
    }
    SPRTF("\n");
}


// main() OS entry
int main( int argc, char **argv )
{
    int iret = 0;
    set_log_file((char *)"tempbuck.txt", false);
    iret = parse_args(argc,argv);
    if (iret) {
        return iret;
    }

    if (got_bbox) {
        show_buckets_in_box();
    }
    // TODO: actions of app

    return iret;
}


// eof = sg_bucket.cxx

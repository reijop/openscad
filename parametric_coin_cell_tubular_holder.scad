// file: parametric_coin_cell_tubular_holder.scad
// version: 1.0 (Initial public draft)
// author: Reijo Pitkanen <reijop@gmail.com>
// desc: what the file name says. takes battery_ parameters and builds a tubular
//       holder for those batteries. could be repurposed for anything, really.
//
// licence: dont-contact-me-its-free (fork and fix - i will not be taking updates)

use <threads.scad>;

// A10/Yellow Tab       5.8 × 3.6
// CR2477               24.5 × 7.7
// CR2040               20.0 x 4.0
// CR1632               16.0 x 3.2
// etc.

// Always read the specs for your specific battery, most are not dimensional to their 
// names.

// default is a CR2477 found lyring around.  measure and adjust
// yourself!

// coin cell dimensions and count
battery_diameter = 24.5;
battery_height = 7.9;
battery_count = 2;

battery_spring_holder = true;

// 
// Here be dragons.
//
debug = false;

// width of all features except walls
feature_width = 1.6;

cylinder_wall_width = 3;

cylinder_plug_height = 9;
cylinder_plug_thread_pitch = 2.5;

cylinder_cap_height = 8;
    groove_count = 5;
    groove_width = 6;
    groove_depth = 2;

// calculated slop between
// (batteries and tray / 2)
// (tray and cylinder)
part_allowance = 0.2;

// thread allowance is ADDITIONAL to part_allowance only on threads.
thread_allowance = 0.3;

// Derived values.
part_batt_cyl_diameter = (battery_diameter + part_allowance + ( 2 * feature_width + part_allowance) + (2 * cylinder_wall_width));
battery_stack_height = feature_width  + (battery_count * (battery_height + part_allowance + feature_width));
part_batt_cyl_height = (battery_stack_height + cylinder_plug_height + cylinder_wall_width + feature_width);

//inner cutout
part_batt_cyl_inner_diameter = (part_batt_cyl_diameter - 2 * cylinder_wall_width); 

tray_diameter = battery_diameter + (feature_width * 2);


// PART battery cylinder
module battery_cylinder() {
    difference() {
    color("green") cylinder(d=part_batt_cyl_diameter,h=part_batt_cyl_height);
    color("white") translate([0,0,-0.005]) cylinder(d=part_batt_cyl_inner_diameter,h=part_batt_cyl_height-cylinder_wall_width);
    color("lightgreen")
       translate([0,0,-0.005])
        rotate([0,0,180])
        metric_thread
                (
                    diameter = part_batt_cyl_diameter - cylinder_wall_width,
                    pitch = cylinder_plug_thread_pitch,
                    length = cylinder_plug_height,
                    internal = true
                );

    if (debug) {cube([part_batt_cyl_diameter,10,10],false);};

    }
}

module battery_cap() {
    difference() {
        color("green") cylinder(d=part_batt_cyl_diameter,h=cylinder_cap_height);

        color("white")
        translate([0,0,-0.003])
        rotate([0,0,-90])
        key();

        for (i=[1:groove_count])  {
         color("white") 
            translate
            (
            [part_batt_cyl_diameter/2*cos(i*(360/groove_count)),
             part_batt_cyl_diameter/2*sin(i*(360/groove_count)),
             groove_depth])
            translate([0,0,0])groove();
        }
    }

    //cap threads
    color("lightgreen")
      translate([0,0,(cylinder_cap_height+cylinder_plug_height) - 0.005])
        rotate([0,180,0])
        metric_thread
                (
                    diameter = part_batt_cyl_diameter - cylinder_wall_width - part_allowance - thread_allowance,
                    pitch = cylinder_plug_thread_pitch,
                    length = cylinder_plug_height,
                    internal = false
                );

    //cap key inside
    color("lime")
        translate([0,0,(cylinder_cap_height+cylinder_plug_height)])
        rotate([0,0,-90])
        key();

     /*
     color("lime")
        translate([0,0,cylinder_plug_height+(cylinder_plug_height-feature_width)])
        rotate([0,0,-90])
        key();
    */

    offset = 360 / (groove_count * 2);
    for (i=[1:groove_count])  {
        rotate([0,0,offset])
        translate
            (
            [part_batt_cyl_diameter/2*cos(i*(360/groove_count)),
             part_batt_cyl_diameter/2*sin(i*(360/groove_count)),
             groove_depth])
            translate([0,0,0]) color("grey") groove();
        }
}

module groove() {
    hull () {
        sphere(d=groove_depth);
        translate([0,0,groove_width-groove_depth]) sphere(d=groove_depth);
    }
}

module battery_tray() {
    rotate([0,0,-90]) keyhole();

    translate([0,0,feature_width]) 
    difference() {
        union() {
            color("green") cylinder (d=tray_diameter, h=battery_stack_height);
        }

        // flat bottom 
        color("white")
          translate([
        -part_batt_cyl_diameter/2,
        tray_diameter/2 - tray_diameter * 0.025,
        -0.005])
          cube([part_batt_cyl_diameter + part_allowance,
                part_batt_cyl_diameter,
                battery_stack_height + feature_width + part_allowance],false) ;

        //halfpipe
        color("white") 
        translate([
        -tray_diameter/2,
        -tray_diameter-part_allowance,
        -0.005])
            cube([tray_diameter + part_allowance,
                  tray_diameter, 
                  battery_stack_height + part_allowance], false);

        // first battery cutout
        color("purple")
            translate([0,0,feature_width])
                cylinder(d=(battery_diameter + part_allowance), h=battery_height + part_allowance);

        if (battery_count > 1) {
            for ( i=[1:battery_count-1] ) {
                color("cyan")
                    translate([0,0, feature_width + ((feature_width + battery_height + part_allowance) * i)])
                        cylinder(d=(battery_diameter + part_allowance), h=battery_height + part_allowance);

            }
        }
    };
}

module key() {
    color("green")
        cylinder(d=tray_diameter/2,h=feature_width, $fn=3);
}

module keyhole() {
    difference() {
        color("green")
        cylinder(d=tray_diameter,h=feature_width);
        color("lime")
        translate([0,0,-0.003])
        cylinder(d=tray_diameter/2,h=feature_width+0.006, $fn=3);
    }
}


// Here not be dragons, these are safe to play with.


// a preceeding "*" negates the whole chain of directives to the ";", in effect
// commenting the whole object out.

// Yay, objects for individual render.  Use these when you re-render the STLs for
// your specific battery (or object).

*battery_cap();
*battery_tray();
battery_cylinder();

// cap with tray, aligned.  May print fucked up.
*union() { battery_cap(); translate([0,0,cylinder_cap_height+cylinder_plug_height]) battery_tray(); };

// Yay, display of objects in a line
*translate([-45,0,0]) battery_cap();
*translate([0,0,0]) battery_tray();
*translate([45,0,0]) 
    rotate([0,180,0]) 
        translate([0,0,-part_batt_cyl_height])
            battery_cylinder();

// Assembled unit for review
module assemble() {
    battery_cap();
    translate([0,0,cylinder_cap_height+cylinder_plug_height]) battery_tray();
    #translate([0,0,cylinder_cap_height]) rotate([0,0,0]) battery_cylinder();
}

*assemble();
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    concat: {
        app: {
            src: ['assets/coffee/utils.coffee', 'assets/coffee/domain/*.coffee',  'assets/coffee/collection/*.coffee', 'assets/coffee/view/*.coffee'],
            dest: 'public/application.coffee'
        },
        jsFiles: {
            src:['assets/js/jquery.js', 'assets/js/jquery.ui.js', 'assets/js/underscore.js', 'assets/js/backbone.js', 'assets/js/jquery.ui.touch.punch.js'],
            dest: 'public/libraries.js'
        }
    },
    watch: {
      all: {
          files: [
            "assets/js/*.coffee",  "assets/coffee/**/*.coffee"
          ],
          tasks: "default"
      }  
    },
    coffee: {
      all:{
          src: ['public/application.coffee'],
          dest: "public/application.js",
          options: {
              bare: false
          }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');

  // Default task.
  grunt.registerTask('default', 'concat coffee');
};
(function($) {
    var BYE_TEAM = { name: 'BYE' };

    function buildRound(name, matches, teams) {
        var roundDom = $('<div class="bracket-round"></div>');

        if (name) {
            $('<div class="bracket-round-title"></div>').html(name).appendTo(roundDom);
        }

        matches.forEach(function (match) {
            buildMatch(match, teams).appendTo(roundDom);
        });

        return roundDom;
    }

    function buildMatch(match, teams) {
        var matchDom = $('<div class="bracket-match"></div>');

        var homeExtra = { score: match.home_score };
        var home = match.home ? $.extend(homeExtra, teams[match.home]) : BYE_TEAM;

        var awayExtra = { score: match.away_score };
        var away = match.away ? $.extend(awayExtra, teams[match.away]) : BYE_TEAM;

        var homeDom = buildTeam(home, 'home').appendTo(matchDom);
        var awayDom = buildTeam(away, 'away').appendTo(matchDom);

        if (match.link) {
            matchDom.on('click', function(event) {
                window.location.href = match.link;
                return false;
            });
        }

        return matchDom;
    }

    function buildTeam(team, type) {
        var teamDom = $('<div class="bracket-team"></div>');
        teamDom.addClass('bracket-team-' + type);
        if (team.id) teamDom.attr('data-team-id', team.id);

        if (team.name) {
            $('<span class="bracket-team-name"></span>').html(team.name).appendTo(teamDom);
        }

        if (team.score) {
            $('<span class="bracket-team-score"></span>').html(team.score).appendTo(teamDom);
        }

        return teamDom;
    }

    function position(origin, element) {
        return {
            x: element.offset().left - origin.offset().left,
            y: element.offset().top - origin.offset().top,
        }
    }

    function leftPosition(origin, element) {
        var pos = position(origin, element);
        return {
            x: pos.x,
            y: pos.y + element.outerHeight() / 2
        };
    }

    function rightPosition(origin, element) {
        var pos = position(origin, element);
        return {
            x: pos.x + element.outerWidth(),
            y: pos.y + element.outerHeight() / 2
        };
    }

    function render(containerj, canvas, target) {
        // Use twice the scale for better resolution on high dpi displays
        var container = containerj[0];
        var width = container.scrollWidth;
        var height = container.scrollHeight;
        canvas.width = width * 2;
        canvas.height = height * 2;
        // Set the canvas style as well
        canvas.style.width = width + 'px';
        canvas.style.height = height + 'px';

        // Set up the canvas context
        var context = canvas.getContext('2d');
        context.clearRect(0, 0, canvas.width, canvas.height);
        context.scale(2, 2);
        context.lineWidth = 4;
        context.strokeStyle = '#00abba';

        var canvasj = $(canvas);
        containerj.find('.bracket-round').each(function() {
            round = $(this);
            var nextRound = round.next('.bracket-round');
            var nextMatches = nextRound.find('.bracket-match');
            if (nextMatches.length == 0) return;

            round.find('.bracket-match').each(function() {
                var match = $(this);
                match.find('.bracket-team[data-team-id="'+target+'"]').each(function() {
                    var team = $(this);
                    var teamId = team.data('team-id');
                    var rightPos = rightPosition(canvasj, team);

                    nextMatches.find("*[data-team-id='" + teamId + "']").each(function (nextTeam) {
                        var nextTeam = $(this);
                        var leftPos = leftPosition(canvasj, nextTeam);
                        leftPos.x = leftPosition(canvasj, nextTeam.parent()).x;

                        // Draw lines between teams
                        context.beginPath();
                        context.moveTo(rightPos.x, rightPos.y);
                        context.lineTo(leftPos.x, leftPos.y);
                        context.stroke();
                    });
                });
            });
        });
    }

    $.fn.bracket = function(options) {
        return this.each(function() {
            var container = $(this);
            container.addClass('bracket-container');

            var rounds = options.rounds;
            var teams = options.teams;
            var matches = options.matches;

            var canvas = $('<canvas class="bracket-canvas"></canvas>').appendTo(container)[0];

            matches.forEach(function (roundMatches, index) {
                buildRound(rounds[index], roundMatches, teams).appendTo(container);
            });

            $('.bracket-team').each(function() {
                $(this).on("mouseover", function(){
                  render(container, canvas, $(this).data("team-id"))
                });
              });

            //$(window).on('resize', function() { render(container, canvas); });
            //render(container, canvas);

            // Scroll to the right of the bracket
            container.scrollLeft(canvas.scrollWidth);
        });
    };
})(jQuery);

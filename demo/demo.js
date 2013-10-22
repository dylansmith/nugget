(function() {
    var nugget = require('../lib/nugget'),
        world,
        em,
        player1;

    world = new nugget.World();
    em = new nugget.EntityManager();

    // define players
    console.log(em);
    player1 = em.createEntity('player1');

})();
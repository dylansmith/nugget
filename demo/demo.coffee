nugget = require '../src/nugget'
config = require '../src/config'
utils = require '../src/utils'

colorize = utils.colorize
log = utils.log
config.debugging = false

em = new nugget.EntityManager()

# bullets are fast, but low damage
bullet = em.createEntity('bullet')
bullet.add('damage', 20)

# missiles are slow, but high damage
missile = em.createEntity('missile')
missile.add('damage', 15)

# player1 has normal health, dodges well and fires many bullets
player1 = em.createEntity('player1')
player1.add('health', 100)
player1.add('dodge', 30)
player1.add('weapon', bullet)
player1.add('ammo', 50)

# the boss has high health, dodges poorly and fires few missiles
boss = em.createEntity('boss')
boss.add('health', 200)
boss.add('dodge', 30)
boss.add('weapon', missile)
boss.add('ammo', 10)

# create the combat system
rounds = 20
currentRound = 1
s_combat = new nugget.System('combat')
s_combat.tickInterval = 0
s_combat.tick = ->
    log colorize("=== ROUND #{currentRound} ===", 'bold')

    # find all entities that can fight
    entities = em.getEntities('weapon, -dead')
    if utils.len(entities) is 1
        log "#{utils.first(entities)} has won the battle!"
        @stop()
        return

    # pick a target for each actor
    for id,actor of entities when actor.get('health').val() > 0
        targets = utils.filter(entities, (id, obj) -> obj isnt actor)
        target = utils.first(targets)
        m = []

        if target?
            m.push colorize("#{actor} targeted #{target}", 'cyan')

            # have ammo?
            ammo = actor.get('ammo').val()
            m.push "  └ ammo = #{ammo}"
            if ammo is 0
                m.push colorize("  └ result = OUT OF AMMO", 'yellow')

            else
                # decrease ammo
                actor.get('ammo').value--

                # calculate if hit
                chanceToHit = utils.rand(0, 100)
                dodge = target.get('dodge').val()
                m.push "  └ chance to hit = #{chanceToHit}, dodge = #{dodge}"

                if dodge > chanceToHit
                    m.push colorize('└ result = DODGED', 'yellow')
                else
                    # calculate the damage done
                    weapon = actor.get('weapon').val()
                    dmg = weapon.get('damage').val()
                    h = target.get('health')
                    h_old = h.val()
                    h_new = if dmg > h.value then 0 else h.value - dmg
                    h.val(h_new)

                    m.push "  └ weapon = #{weapon}, damage = #{dmg}"
                    m.push colorize("  └ result = HIT! #{target}'s health decreased from #{h_old} to #{h.val()}", 'green')

                if h_new <= 0
                    target.add('dead')
                    m.push colorize("  └ #{target} was destroyed.", 'red')

        else
            m.push "#{actor} has vanquished all enemies."

        log msg for msg in m

    # check if we should stop
    @stop() if currentRound >= rounds
    currentRound++

s_combat.start()

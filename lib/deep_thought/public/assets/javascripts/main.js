$(document).ready(function() {
  var actionNumber = 1;
  var variableNumber = 1;

  $('#add-action').click(function(event) {
    $('<div class="field"><label class="two-column left">action ' + actionNumber + ':</label><input class="two-column right box" id="action' + actionNumber + '" name="deploy[actions][]" placeholder="action" type="text"></div>').insertBefore($(this).parent());
    actionNumber++;
  });

  $('#add-variable').click(function(event) {
    $('<div class="field"><input class="two-column left box" id="key' + variableNumber + '" name="deploy[variables][keys][]" placeholder="key" type="text"><input class="two-column right box" id="value' + variableNumber + '" name="deploy[variables][values][]" placeholder="value" type="text"></div>').insertBefore($(this).parent());
    variableNumber++;
  });
});

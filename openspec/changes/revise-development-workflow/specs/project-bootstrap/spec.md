## MODIFIED Requirements

### Requirement: The workflow rules name a role before naming a tool

The workflow rule fragment SHALL state each obligation as a role to be filled, and MAY name a specific agent or command beneath it as one harness's binding for that role.

A rule that names only a tool becomes a dangling reference in any project where that tool is absent, which makes a single harness a hard dependency of the methodology rather than its first adapter.

A binding MAY additionally name a tool that SHALL NOT fill the role it sits beneath, where a plausible wrong candidate exists. Naming only the correct tool leaves the wrong one available to anything reading the role description alone, and a role whose description matches a tool the project ships is filled by that tool whether or not it is the intended one. Where a negative binding is stated, it SHALL say why the excluded tool does not fill the role, so that a reader can tell an exclusion from an arbitrary preference.

Both the positive and the negative form are bindings, and neither SHALL appear in the role sentence: a role stated in terms of one harness's tool names is not portable, which is what this requirement exists to prevent.

#### Scenario: Rules remain meaningful without the toolkit installed

- **WHEN** a project's conventions file carries the managed block but the library is not installed in that project
- **THEN** each rule still states what must happen and why, and the named agents read as one harness's bindings rather than as required references

#### Scenario: A plausible wrong tool is excluded by name

- **WHEN** the fragment states a role whose description also matches a tool the library ships for a different role
- **THEN** the binding beneath that role names the excluded tool and states why it does not fill the role, and the role sentence above it names no tool at all

#### Scenario: An excluded tool's own contract is what the exclusion rests on

- **WHEN** a reader checks a negative binding against the excluded tool
- **THEN** the reason stated is one the excluded tool's own description supports, rather than a preference asserted only by the fragment

## ADDED Requirements

### Requirement: The workflow rules state an ordered sequence whose gates have checkable preconditions

The workflow rule fragment SHALL state the order in which its obligations are discharged, not only the set of obligations. Where one obligation must precede another, the fragment SHALL say so.

For each gate in that order, the fragment SHALL name what must be observably present before the gate is passed — an artifact that exists, a verdict that was returned, a commit that was made — rather than describing the gate only as a stage that has been reached.

A rule stating that a step comes "after" another, without naming an observable that distinguishes done from not-done, is one an agent satisfies by asserting the earlier step happened. An unordered set of obligations is weaker still: every rule can be individually satisfied while the work runs in an order that defeats all of them, and nothing is violated. Both failures are silent, which is why the ordering and its observables are specified here rather than left to the fragment's author.

Where a precondition for a gate is absent, the fragment SHALL direct that the missing step be taken before the gate, rather than that the gate be passed with the gap noted.

A precondition MAY be waived by an exemption stated in advance — in this specification, in another specification it names, or in the project's own rules — identifying the class of change exempted and the reason. The fragment SHALL distinguish such an exemption from a gap found at the gate, and SHALL require the reason to be stated when the exemption is used. The two are not the same act: an exemption stated in advance is a decision recorded where the next reader finds it, whereas a gap noted at the gate is a judgment made by whoever happened to arrive there, invisible to anyone who did not. A specification that forbids both forbids the recorded decision along with the unrecorded one, which forces a gate that some legitimate change cannot pass.

#### Scenario: A stage boundary names an observable rather than a stage

- **WHEN** the fragment states that implementation follows review and test authoring
- **THEN** it names what must exist before implementation begins — the review verdict, the commit holding the approved plan, and the tests derived from that plan — rather than stating only that review and test authoring are earlier stages

#### Scenario: An obligation dispatched against incomplete inputs is prevented, not merely discouraged

- **WHEN** the fragment states an obligation discharged by dispatching a reviewer or test author against a change's artifacts
- **THEN** it states which artifacts must be complete before that dispatch, so that dispatching against a partial package is a precondition failure rather than a judgment call

#### Scenario: A missing precondition halts rather than annotates

- **WHEN** an agent following the fragment reaches a gate whose precondition is absent and no exemption stated in advance covers it
- **THEN** the fragment directs it to take the missing step first, and states no alternative in which the gate is passed and the gap recorded

#### Scenario: An exemption stated in advance is not a gap noted at the gate

- **WHEN** a precondition is unsatisfiable for a class of change that a specification or a project rule has already exempted, naming the class and the reason
- **THEN** the gate is passed without that precondition and the exemption's reason is stated, while a precondition merely found absent at the gate still halts

#### Scenario: A gate does not foreclose a change that structurally cannot satisfy it

- **WHEN** a change cannot produce one of a gate's preconditions because that precondition's own inputs are outputs of the change itself
- **THEN** the fragment admits the stated exemption covering it, rather than describing a gate no such change can pass

### Requirement: An automatic agent-dispatch loop stated by the rules is bounded

Where the workflow rule fragment states an obligation discharged by repeatedly dispatching an agent until a condition is met, it SHALL state a bound on how many of those dispatches happen without asking, and SHALL state what the agent does on reaching the bound: report where the loop stands and what is outstanding, and ask before continuing.

The bound SHALL be stated as a role-level obligation, not only inside a harness binding. A bound that lives only in a binding is absent from every project that fills the role by other means, and an unbounded loop is the more expensive failure precisely where the binding is unfamiliar.

The fragment SHALL further state which outcomes exit the loop rather than consume a round. An outcome that no amount of revision answers — a judgment against the change's concept rather than against its artifacts — is not a round of the loop, and treating it as one spends the bound on revisions that cannot succeed.

An unbounded loop dispatches an agent repeatedly against work no one has looked at since it started, and converges or does not with nothing reporting which.

#### Scenario: The bound is reached rather than exceeded

- **WHEN** a loop the fragment states has run its stated number of automatic dispatches without meeting its exit condition
- **THEN** the fragment directs the agent to report the loop's state and what is outstanding, and to ask before dispatching again

#### Scenario: The bound survives the binding being absent

- **WHEN** a project carries the managed block and fills a looping role by some means other than the named binding
- **THEN** the bound and the ask-on-reaching-it obligation are still stated, because they sit in the role rather than in the binding

#### Scenario: A non-revisable outcome exits rather than iterates

- **WHEN** the outcome of a dispatch is a judgment that revision cannot address
- **THEN** the fragment directs the loop to stop and raise it at once, whatever the count stands at, rather than counting it as a round

### Requirement: The fragment's version increments when its body changes

A rule fragment's `version` SHALL increment whenever the body text inlined into a project changes. This is stated for the workflow rule fragment, which is the only fragment inlined today, and holds for any other fragment this capability inlines. It SHALL NOT increment for a change confined to the fragment's own frontmatter, and it SHALL NOT remain unchanged across a body edit.

The version is what a project's managed block records, and the only thing distinguishing an adopted copy from a current one. A body edit that leaves the version alone makes every project carrying the old text indistinguishable from one carrying the new, which defeats the marker's stated purpose of answering which version a project adopted.

This requirement owns when the version increments. `toolkit-structure` fixes the frontmatter's form and states that the version is unrelated to any package or plugin version; it defers the increment condition here by name, so that an author checking a fragment edit reaches one answer rather than two.

#### Scenario: An edited fragment is distinguishable from the copy already adopted

- **WHEN** the fragment's body is edited and a project already carries a managed block of the previous text
- **THEN** the version the tool carries differs from the version recorded in that project's block, and the skew is therefore reportable

#### Scenario: A frontmatter-only edit does not consume a version

- **WHEN** the fragment's frontmatter changes while the body inlined into a project does not
- **THEN** the version is unchanged, because no project's inlined text differs from any other's

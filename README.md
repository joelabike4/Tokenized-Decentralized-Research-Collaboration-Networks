# Tokenized Decentralized Research Collaboration Networks

A comprehensive blockchain-based platform for managing scientific research collaboration, peer review, funding distribution, data sharing, and publication verification using Clarity smart contracts on the Stacks blockchain.

## Overview

This project implements a decentralized research ecosystem that enables:

- **Research Proposal Management**: Submit and track scientific project proposals with staking mechanisms
- **Anonymous Peer Review**: Facilitate expert evaluation of research proposals with reputation systems
- **Merit-Based Funding Distribution**: Allocate grants based on review scores and proposal quality
- **Secure Data Sharing**: Enable controlled access to research data with permission management
- **Publication Verification**: Validate research authenticity through community verification

## Architecture

The system consists of five independent smart contracts:

### 1. Research Proposal Contract (\`research-proposal.clar\`)
- Manages scientific project submissions
- Implements staking mechanism to ensure proposal quality
- Tracks proposal lifecycle and researcher history
- Provides deadline management for review processes

### 2. Peer Review Contract (\`peer-review.clar\`)
- Facilitates anonymous expert evaluation
- Implements reputation-based reviewer qualification
- Aggregates review scores and manages review completion
- Tracks reviewer performance and accuracy

### 3. Funding Distribution Contract (\`funding-distribution.clar\`)
- Creates and manages funding rounds
- Allocates grants based on merit and review scores
- Tracks budget allocation and disbursement
- Maintains researcher funding history

### 4. Data Sharing Contract (\`data-sharing.clar\`)
- Enables secure research data exchange
- Implements granular access control permissions
- Manages data access requests and approvals
- Tracks data usage and citation requirements

### 5. Publication Verification Contract (\`publication-verification.clar\`)
- Validates research authenticity
- Manages community-based verification process
- Tracks publication metadata and verification scores
- Maintains author and journal publication records

## Key Features

### Staking Mechanism
- Researchers must stake STX tokens when submitting proposals
- Stakes are returned upon successful completion or rejection
- Prevents spam and ensures serious proposal submissions

### Reputation System
- Reviewers build reputation through accurate and timely reviews
- Minimum reputation thresholds for review participation
- Dynamic reputation adjustments based on review quality

### Merit-Based Funding
- Funding allocation based on peer review scores
- Transparent budget tracking and allocation history
- Support for multiple concurrent funding rounds

### Access Control
- Granular permissions for data access (read, write, admin)
- Time-based access expiration
- Request-approval workflow for data access

### Verification Consensus
- Community-based publication verification
- Configurable verification thresholds
- Prevention of self-verification and duplicate verifications

## Smart Contract Functions

### Research Proposal Contract

#### Public Functions
- \`submit-proposal\`: Submit a new research proposal with stake
- \`update-proposal-status\`: Update proposal status (owner only)
- \`withdraw-stake\`: Withdraw stake after proposal completion
- \`set-min-stake-amount\`: Configure minimum stake requirement

#### Read-Only Functions
- \`get-proposal\`: Retrieve proposal details
- \`get-proposal-metadata\`: Get additional proposal information
- \`get-researcher-proposals\`: List proposals by researcher
- \`get-proposal-counter\`: Get total number of proposals

### Peer Review Contract

#### Public Functions
- \`submit-review\`: Submit a peer review with scores and comments
- \`update-reviewer-reputation\`: Adjust reviewer reputation (owner only)
- \`set-min-reviewer-reputation\`: Set minimum reputation threshold

#### Read-Only Functions
- \`get-review\`: Retrieve review details
- \`get-reviewer-reputation\`: Get reviewer reputation data
- \`get-proposal-reviews\`: Get all reviews for a proposal
- \`has-reviewed\`: Check if reviewer has reviewed a proposal

### Funding Distribution Contract

#### Public Functions
- \`create-funding-round\`: Create a new funding round (owner only)
- \`allocate-funding\`: Allocate funds to proposals (owner only)
- \`update-disbursement-status\`: Update funding disbursement status
- \`close-funding-round\`: Close a funding round

#### Read-Only Functions
- \`get-funding-round\`: Retrieve funding round details
- \`get-funding-allocation\`: Get allocation information
- \`get-researcher-funding\`: Get researcher funding history
- \`get-total-funding-pool\`: Get total available funding

### Data Sharing Contract

#### Public Functions
- \`upload-data\`: Upload research data with metadata
- \`request-data-access\`: Request access to research data
- \`grant-data-access\`: Grant access permissions (owner only)
- \`revoke-data-access\`: Revoke access permissions (owner only)
- \`review-access-request\`: Approve or reject access requests

#### Read-Only Functions
- \`get-research-data\`: Retrieve data metadata
- \`get-data-permissions\`: Check user permissions for data
- \`get-access-request\`: Get access request details
- \`can-access-data\`: Check if user can access specific data

### Publication Verification Contract

#### Public Functions
- \`submit-publication\`: Submit a publication for verification
- \`verify-publication\`: Verify a publication (non-authors only)
- \`update-publication-status\`: Update publication status (owner only)
- \`set-min-verifications-required\`: Set verification threshold

#### Read-Only Functions
- \`get-publication\`: Retrieve publication details
- \`get-publication-verifications\`: Get verification statistics
- \`get-verifier-record\`: Get individual verifier records
- \`get-author-publications\`: List publications by author

## Installation and Deployment

### Prerequisites
- Stacks blockchain development environment
- Clarity CLI tools
- Node.js and npm for testing

### Deployment Steps

1. **Clone the repository**
   \`\`\`bash
   git clone <repository-url>
   cd tokenized-research-network
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   npm install
   \`\`\`

3. **Run tests**
   \`\`\`bash
   npm test
   \`\`\`

4. **Deploy contracts**
   \`\`\`bash
   # Deploy each contract individually
   stx deploy contracts/research-proposal.clar
   stx deploy contracts/peer-review.clar
   stx deploy contracts/funding-distribution.clar
   stx deploy contracts/data-sharing.clar
   stx deploy contracts/publication-verification.clar
   \`\`\`

## Usage Examples

### Submitting a Research Proposal

\`\`\`clarity
(contract-call? .research-proposal submit-proposal
"AI-Driven Climate Modeling"
"Research on using artificial intelligence for climate prediction models"
"Climate Science"
u50000000000  ;; 50,000 STX funding requested
u1000000      ;; 1 STX stake
"AI, climate, modeling, prediction"
"Machine learning algorithms applied to historical climate data"
"Improved climate prediction accuracy by 15%"
u24)          ;; 24 months timeline
\`\`\`

### Submitting a Peer Review

\`\`\`clarity
(contract-call? .peer-review submit-review
u1            ;; proposal-id
u8            ;; technical-score
u7            ;; novelty-score
u9            ;; feasibility-score
u8            ;; impact-score
"Well-structured research with clear methodology"
true)         ;; is-anonymous
\`\`\`

### Creating a Funding Round

\`\`\`clarity
(contract-call? .funding-distribution create-funding-round
u100000000000  ;; 100,000 STX budget
u8640)         ;; ~60 days duration in blocks
\`\`\`

### Uploading Research Data

\`\`\`clarity
(contract-call? .data-sharing upload-data
"Climate Temperature Dataset 2024"
"Comprehensive temperature measurements from global weather stations"
"a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"
"CSV"
u1048576      ;; 1MB size
"restricted"
"CC-BY-4.0"
true)         ;; citation-required
\`\`\`

### Submitting a Publication

\`\`\`clarity
(contract-call? .publication-verification submit-publication
"Blockchain Applications in Scientific Research: A Comprehensive Review"
"This paper explores the potential applications of blockchain technology..."
(list 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC)
"Journal of Blockchain Science"
"10.1000/blockchain.2024.001"
"Computer Science"
"b1c2d3e4f5a6789012345678901234567890abcdef1234567890abcdef123456"
"Data available upon request from corresponding author"
true)         ;; open-access
\`\`\`

## Testing

The project includes comprehensive test suites for all contracts using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific contract tests
npm test research-proposal
npm test peer-review
npm test funding-distribution
npm test data-sharing
npm test publication-verification
\`\`\`

Test coverage includes:
- Contract function validation
- Error handling and edge cases
- Data integrity and state management
- Access control and permissions
- Business logic verification

## Security Considerations

### Access Control
- Owner-only functions for administrative operations
- Researcher-specific permissions for data and proposals
- Reputation-based access for peer review participation

### Data Integrity
- Content hashing for data and publication verification
- Immutable proposal and review records
- Transparent funding allocation tracking

### Economic Security
- Staking mechanisms to prevent spam
- Reputation systems to ensure quality participation
- Budget controls and allocation limits

## Governance

### Contract Ownership
- Each contract has an owner (deployer) with administrative privileges
- Owner can update system parameters and resolve disputes
- Consider implementing multi-signature or DAO governance for production

### Parameter Configuration
- Minimum stake amounts for proposals
- Reviewer reputation thresholds
- Verification requirements for publications
- Funding round parameters

## Future Enhancements

### Potential Improvements
1. **Cross-Contract Integration**: Enable contracts to interact for workflow automation
2. **Token Economics**: Implement native research tokens for incentives
3. **Advanced Reputation**: Machine learning-based reputation scoring
4. **Decentralized Storage**: Integration with IPFS or Arweave for data storage
5. **Mobile Interface**: Mobile applications for researcher interaction
6. **Analytics Dashboard**: Real-time metrics and research network analytics

### Scalability Considerations
- Implement pagination for large data sets
- Consider layer-2 solutions for high-frequency operations
- Optimize storage patterns for gas efficiency

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request with detailed description

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or contributions:
- Create an issue in the repository
- Join our community discussions
- Contact the development team

## Acknowledgments

- Stacks blockchain community for development tools and support
- Research community for requirements and feedback
- Open source contributors and reviewers
